import SwiftUI
import FoundationModels
import TipKit

struct FeedView: View {
    @State private var currentIndex = 0
    @State private var currentOffset: CGFloat = 0
    @State private var lastIndex = 0
    //    @State private var lastScore = 0
    @Environment(DataManager.self) var dataManager
    @State private var isAutoscrolling = false
    @State private var timer: Timer?
    @State private var lastAutoscroll = false
    @State var tips = TipGroup(.ordered) {
        ScrollTip()
        LikeTip()
        FollowTip()
    }
    var openedVideos: [Video] = []
    @State private var feed: [Video] = []
    @State private var cannotGenAlert = false
    @State private var genError = ""
    @State private var heartOpacity = 0.0
    var body: some View {
        @Bindable var dataManager = dataManager
        GeometryReader { geometry in
            NavigationStack{
                if !feed.isEmpty{
                    ZStack{
                        HStack{
                            Spacer()
                            VStack{
                                Button{
                                    if currentIndex > 0{
                                        currentIndex -= 1
                                    }
                                }label: {
                                    Image(systemName: "chevron.up")
                                        .frame(width: 50, height: 50)
                                        .glassEffect(.regular.interactive())
                                }
                                .disabled(currentIndex == 0)
                                .foregroundStyle(currentIndex == 0 ? .gray : Color.accentColor)
                                if dataManager.autoscroll{
                                    Button{
                                        isAutoscrolling.toggle()
                                    }label: {
                                        Image(systemName: isAutoscrolling ? "pause.fill" : "play.fill")
                                            .frame(width: 50, height: 50)
                                            .glassEffect(.regular.interactive())
                                    }
                                    .contentTransition(.symbolEffect(.replace))
                                    .onChange(of: isAutoscrolling) {
                                        if isAutoscrolling{
                                            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                                                Task { @MainActor in
                                                    if currentIndex < feed.count - 1 {
                                                        currentIndex += 1
                                                    }
                                                }
                                            }
                                            
                                        }else{
                                            timer?.invalidate()
                                        }
                                    }
                                    .onAppear(){
                                        if dataManager.autoscroll && !lastAutoscroll{
                                            isAutoscrolling = true
                                            lastAutoscroll = true
                                        }
                                    }
                                }
                                Button{
                                    if currentIndex < feed.count - 1{
                                        currentIndex += 1
                                    }
                                    if tips.currentTip is LikeTip{
                                        tips.currentTip?.invalidate(reason: .actionPerformed)
                                    }
                                }label: {
                                    Image(systemName: "chevron.down")
                                        .frame(width: 50, height: 50)
                                        .glassEffect(.regular.interactive())
                                }
                                .disabled(currentIndex >= feed.count - 1)
                                .foregroundStyle(currentIndex >= feed.count - 1 ? .gray : Color.accentColor)
                                .popoverTip(tips.currentTip as? ScrollTip)
                            }
                            
                            ZStack{
                                
                                ScrollViewReader{ proxy in
                                    ScrollView{
                                        VStack{
                                            ForEach(Array(feed.enumerated()), id: \.element.id) { index, video in
                                                VStack {
                                                    HStack{
                                                        Spacer()
                                                        Image(systemName: premadeVideos.contains(video) ? "person.crop.circle" : "apple.intelligence")
                                                            .font(.largeTitle)
                                                    }
                                                    Spacer()
                                                    Text(video.text)
                                                        .font(.largeTitle)
                                                        .foregroundStyle(.black)
                                                        .padding()
                                                        .background(.white)
                                                        .mask{
                                                            RoundedRectangle(cornerRadius: 10)
                                                        }
                                                        .multilineTextAlignment(.center)
                                                    Spacer()
                                                    if UIImage(systemName: video.image) != nil{
                                                        Image(systemName: video.image)
                                                            .font(.system(size: 100))
                                                    }else if video.emoji.count == 1{
                                                        Text(video.emoji)
                                                            .font(.system(size: 100))
                                                    }else{
                                                        Image(systemName: "video")
                                                            .font(.system(size: 100))
                                                    }
                                                    Spacer()
                                                    HStack{
                                                        VStack(alignment: .leading){
                                                            Text(video.creator)
                                                                .bold()
                                                            Text(video.caption)
                                                            HStack{
                                                                ForEach(Array(video.tags), id: \.self){tag in
                                                                    NavigationLink{
                                                                        TagView(tag: tag)
                                                                    }label:{
                                                                        Text("#\(tag)")
                                                                            .bold()
                                                                    }
                                                                }
                                                            }
                                                            .zIndex(100)
                                                            
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 50)
                                                }
                                                .foregroundStyle(.white)
                                                .padding()
                                                .frame(maxWidth: geometry.size.height*9/16,minHeight: geometry.size.height*19/20, maxHeight: geometry.size.height)
                                                .background(Color.accentColor)
                                                .mask{
                                                    RoundedRectangle(cornerRadius: 50)
                                                }
                                                .id(index)
                                            }
                                        }
                                        .offset(y: currentOffset)
                                        
                                    }
                                    .scrollDisabled(true)
                                    .scrollIndicators(.hidden)
                                    .alert("Unable to generate video:",isPresented: $cannotGenAlert){} message: {
                                        Text(genError)
                                    }
                                    .onChange(of: currentIndex) {
                                        if currentIndex + 1 >= feed.count{
                                            if let nextVideo = dataManager.videos.rankedVideos(dataManager: dataManager).filter({!feed.contains($0)}).first{
                                                feed.append(nextVideo)
                                            }else{
                                                print("touch grass")
                                            }
                                        }
                                        if currentIndex>lastIndex{
                                            lastIndex = currentIndex
                                            dataManager.videoCount += 1
                                            if !openedVideos.contains(feed[currentIndex]){
                                                for tag in feed[currentIndex].tags{
                                                    if dataManager.likedTags.subtracting(additionalTags).contains(tag){
                                                        dataManager.score += 1
                                                    }
                                                }
                                                if dataManager.following.contains(feed[currentIndex].creator){
                                                    dataManager.score += 1
                                                }
                                            }
                                            Task{
                                                do{
                                                    let video = try await feedGenerateVideo(dataManager: dataManager)
                                                    dataManager.videos.append(video)
                                                }catch{
                                                    if genError != error.localizedDescription{
                                                        cannotGenAlert = true
                                                    }
                                                    genError = error.localizedDescription
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            if openedVideos.isEmpty{
                                                if let friendIndex = dataManager.chats.firstIndex(where: {$0.user == "bobby1479"}), let momIndex = dataManager.chats.firstIndex(where: {$0.user == "danielletan73"}){
                                                    if lastIndex == 10{
                                                        dataManager.chats[friendIndex].messages.append(Message(isMe: false, text: "yo bro"))
                                                    }else if lastIndex == 15{
                                                        if !dataManager.tasks.contains(where: {$0.name == "bowlingmeet"}){
                                                            dataManager.tasks.append(ATask(name: "study", title: "Study for your test tomorrow", image: "text.page", points: 5))
                                                            isAutoscrolling = false
                                                        }
                                                    }else if lastIndex == 20{
                                                        if let study = dataManager.tasks.first(where: {$0.name == "study"}), !study.done{
                                                            dataManager.chats[momIndex].messages.append(Message(isMe: false, text: "Son"))
                                                        }
                                                    }else if lastIndex == 30{
                                                        if !dataManager.store{
                                                            dataManager.store = true
                                                        }
                                                    }
                                                    if let bowl = dataManager.tasks.first(where: {$0.name == "bowlingmain"}), !bowl.done, !dataManager.chats[friendIndex].messages.contains(where: {$0.text == "Bro can you get off your phone"}){
                                                        dataManager.chats[friendIndex].messages.append(Message(isMe: false, text: "Bro can you get off your phone"))
                                                    }
                                                }
                                            }
                                        }
                                        withAnimation {
                                            proxy.scrollTo(currentIndex)
                                        }
                                    }
                                    .onChange(of: dataManager.tabSelection) {
                                        isAutoscrolling = dataManager.tabSelection == "feed"
                                    }
                                }
                                Rectangle()
                                    .frame(maxWidth: geometry.size.height*9/16, maxHeight: .infinity)
                                    .ignoresSafeArea()
                                    .opacity(0.01)
                                    .scaleEffect(y: 0.95)
                                    .gesture(DragGesture()
                                        .onChanged{ value in
                                            currentOffset = value.translation.height
                                        }
                                        .onEnded { value in
                                            if value.translation.height > geometry.size.height/4 && currentIndex > 0{
                                                if currentIndex > 0{
                                                    currentIndex -= 1
                                                }
                                            }else if value.translation.height <  geometry.size.height / -4{
                                                if currentIndex < feed.count - 1{
                                                    currentIndex += 1
                                                }
                                            }
                                            withAnimation {
                                                currentOffset = 0
                                            }
                                            
                                            
                                        })
                                    .simultaneousGesture(
                                        TapGesture(count: 2)
                                            .onEnded {
                                                if dataManager.likedVideos.contains(feed[currentIndex]){
                                                    dataManager.likedVideos.removeAll(where: {$0 == feed[currentIndex]})
                                                }else{
                                                    dataManager.likedVideos.append(feed[currentIndex])
                                                    dataManager.likedTags.formUnion(feed[currentIndex].tags)
                                                    withAnimation(.easeIn(duration: 0.2)) {
                                                        heartOpacity = 1.0
                                                    }
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                            heartOpacity = 0.0
                                                        }
                                                    }
                                                }
                                                if tips.currentTip is LikeTip{
                                                    tips.currentTip?.invalidate(reason: .actionPerformed)
                                                }
                                            }
                                    )
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30))
                                    .padding()
                                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 25))
                                    .opacity(heartOpacity)
                            }
                            VStack{
                                GlassEffectContainer(spacing: 30){
                                    VStack{
                                        NavigationLink{
                                            ProfileView(name: feed[currentIndex].creator)
                                        }label: {
                                            Image(systemName: "person.crop.circle")
                                                .frame(width: 50, height: 50)
                                                .glassEffect(.regular.interactive())
                                        }
                                        Button{
                                            if dataManager.following.contains(feed[currentIndex].creator){
                                                dataManager.following.remove(feed[currentIndex].creator)
                                            }else{
                                                dataManager.following.insert(feed[currentIndex].creator)
                                            }
                                            if tips.currentTip is FollowTip{
                                                tips.currentTip?.invalidate(reason: .actionPerformed)
                                            }
                                        }label: {
                                            Image(systemName: dataManager.following.contains(feed[currentIndex].creator) ? "checkmark" : "plus")
                                                .frame(width: 50, height: 50)
                                                .glassEffect(.regular.interactive())
                                        }
                                        .contentTransition(.symbolEffect(.replace))
                                        .popoverTip(tips.currentTip as? FollowTip)
                                    }
                                }
                                Button{
                                    if dataManager.likedVideos.contains(feed[currentIndex]){
                                        dataManager.likedVideos.removeAll(where: {$0 == feed[currentIndex]})
                                    }else{
                                        dataManager.likedVideos.append(feed[currentIndex])
                                        dataManager.likedTags.formUnion(feed[currentIndex].tags)
                                    }
                                    if tips.currentTip is LikeTip{
                                        tips.currentTip?.invalidate(reason: .actionPerformed)
                                    }
                                }label: {
                                    Image(systemName: dataManager.likedVideos.contains(feed[currentIndex]) ? "heart.fill" :"heart")
                                        .frame(width: 50, height: 50)
                                        .glassEffect(.regular.interactive())
                                }
                                .popoverTip(tips.currentTip as? LikeTip)
                            }
                            Spacer()
                        }
                        HStack{
                            VStack{
                                
                                Spacer()
                            }
                            Spacer()
                            VStack{
                                TasksView()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }else{
                    Rectangle()
                        .onAppear(){
                            if openedVideos.isEmpty{
                                feed = Array(dataManager.videos.rankedVideos(dataManager: dataManager).prefix(3))
                                for tag in feed[currentIndex].tags{
                                    if dataManager.likedTags.contains(tag){
                                        dataManager.score += 1
                                    }
                                }
                            }else{
                                feed = openedVideos
                                feed.append(contentsOf: Array(dataManager.videos.rankedVideos(dataManager: dataManager, videos: openedVideos).prefix(3)))
                            }
                        }
                }
            }
        }
    }
}
extension [Video]{
    func rankedVideos(dataManager: DataManager, videos: [Video] = []) -> [Video] {
        let tags = Set(videos.flatMap(\.tags))
        return self.filter{!(videos.isEmpty ? dataManager.likedVideos : videos).contains($0)}.map{ video in
            (video, video.tags.filter{(tags.isEmpty ? dataManager.likedTags : tags).contains($0)}.count)
        }
        .sorted(by: { $0.1 > $1.1 })
        .map{$0.0}
    }
}
struct VideoView: View {
    var video: Video
    var body: some View {
        VStack {
            Spacer()
            Text(video.text)
                .font(.largeTitle)
                .foregroundStyle(.black)
                .padding()
                .background(.white)
                .mask{
                    RoundedRectangle(cornerRadius: 10)
                }
                .multilineTextAlignment(.center)
            Spacer()
            if UIImage(systemName: video.image) != nil{
                Image(systemName: video.image)
                    .font(.system(size: 100))
            }else{
                Image(systemName: "video")
                    .font(.system(size: 100))
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
    }
}


struct LikeTip: Tip{
    var title: Text {
        Text("Liking videos")
    }
    var message: Text? {
        Text("Double tap the screen or click this to see more videos like this one and be able to earn more dopamine points!")
    }
    var image: Image? {
        Image(systemName: "heart")
    }
}
struct FollowTip: Tip{
    var title: Text {
        Text("Following creators")
    }
    var message: Text? {
        Text("Follow creators to see more of their videos and earn even more dopamine points!")
    }
    var image: Image? {
        Image(systemName: "person.3.fill")
    }
}
struct ScrollTip: Tip{
    var title: Text{
        Text("Scrolling")
    }
    var message: Text?{
        Text("Swipe or use this button to go to the next video")
    }
    var image: Image?{
        Image(systemName: "play.square.stack")
    }
}
struct TagView: View {
    var tag: String
    @Environment(DataManager.self) var dataManager
    var filteredVideos: [Video]{
        dataManager.videos.filter({$0.tags.contains(tag)})
    }
    var body: some View {
        NavigationStack{
            ScrollView(.vertical){
                
                VStack{
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                        ForEach(filteredVideos){video in
                            NavigationLink{
                                FeedView(openedVideos: Array(filteredVideos.dropFirst(filteredVideos.firstIndex(of: video) ?? 0)))
                            }label:{
                                VideoView(video: video)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(9.0/16.0, contentMode: .fit)
                                    .background(Color.accentColor)
                                    .mask{
                                        RoundedRectangle(cornerRadius: 50)
                                    }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("#\(tag)")
        }
    }
}
#Preview {
    TagView(tag: "food")
        .environment(DataManager())
}
