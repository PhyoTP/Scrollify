import SwiftUI
import FoundationModels
import TipKit

struct FeedView: View {
    @State private var currentIndex = 0
    @State private var currentOffset: CGFloat = 0
    @State private var likedVideos: [Video] = []
    @State private var feed: [Video] = []
    @Binding var videos: [Video]
    @State private var lastIndex = 0
    @State private var lastScore = 0
    @Binding var following: Set<String>
    @Environment(DataManager.self) var dataManager
    @State private var isAutoscrolling = false
    @State private var timer: Timer?
    @State private var lastAutoscroll = false
    @State var tips = TipGroup(.ordered) {
            LikeTip()
            FollowTip()
        }
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
                                        .glassEffect(.regular)
                                }
                                if dataManager.autoscroll{
                                    Button{
                                        isAutoscrolling.toggle()
                                    }label: {
                                        Image(systemName: isAutoscrolling ? "pause.fill" : "play.fill")
                                            .frame(width: 50, height: 50)
                                            .glassEffect(.regular)
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
                                }label: {
                                    Image(systemName: "chevron.down")
                                        .frame(width: 50, height: 50)
                                        .glassEffect(.regular)
                                }
                            }
                            
                            ZStack{
                                
                                ScrollViewReader{ proxy in
                                    ScrollView{
                                        VStack{
                                            ForEach(Array(feed.enumerated()), id: \.element.id) { index, video in
                                                PlayingVideoView(video: video, following: $following)
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
                                    .scrollIndicators(.hidden)
                                    .onChange(of: currentIndex) {
                                        if currentIndex + 1 >= feed.count{
                                            if let nextVideo = videos.rankedVideos(likedTags: dataManager.likedTags).filter({!feed.contains($0)}).first{
                                                feed.append(nextVideo)
                                            }else{
                                                print("touch grass")
                                            }
                                        }
                                        if currentIndex>lastIndex{
                                            lastIndex = currentIndex
                                            lastScore = 0
                                            for tag in feed[currentIndex].tags{
                                                if dataManager.likedTags.subtracting(additionalTags).contains(tag){
                                                    dataManager.score += 1
                                                    withAnimation {
                                                        lastScore+=1
                                                    }
                                                }
                                            }
                                            if following.contains(feed[currentIndex].creator){
                                                dataManager.score += 1
                                            }
                                            Task{
                                                do{
                                                    let video = try await generateVideo(likedTags: dataManager.likedTags, creators: following, allVideos: videos)
                                                    feed.append(video)
                                                    videos.append(video)
                                                }catch{
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            if let friendIndex = dataManager.chats.firstIndex(where: {$0.user == "bobby1479"}), let momIndex = dataManager.chats.firstIndex(where: {$0.user == "danielletan73"}){
                                                if lastIndex == 10{
                                                    dataManager.chats[friendIndex].messages.append(Message(isMe: false, text: "yo bro"))
                                                }else if lastIndex == 20{
                                                    if dataManager.chats[friendIndex].messages.last?.text == "alr then see you in 30"{
//                                                        dataManager.chats[friendIndex].messages.append(Message(isMe: false, text: "bro u here yet"))
                                                    }else{
                                                        dataManager.chats[momIndex].messages.append(Message(isMe: false, text: "Son"))
                                                    }
                                                }
                                            }
                                        }
                                        withAnimation {
                                            proxy.scrollTo(currentIndex)
                                        }
                                    }
                                }
                                Rectangle()
                                    .frame(maxWidth: geometry.size.height*9/16, maxHeight: .infinity)
                                    .ignoresSafeArea()
                                    .opacity(0.01)
                                    .simultaneousGesture(DragGesture()
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
                            }
                            VStack{
                                GlassEffectContainer(spacing: 30){
                                    VStack{
                                        NavigationLink{
                                            ProfileView(videos: videos, name: feed[currentIndex].creator, following: $following)
                                        }label: {
                                            Image(systemName: "person.crop.circle")
                                                .frame(width: 50, height: 50)
                                                .glassEffect(.regular.interactive())
                                        }
                                        Button{
                                            if following.contains(feed[currentIndex].creator){
                                                following.remove(feed[currentIndex].creator)
                                            }else{
                                                following.insert(feed[currentIndex].creator)
                                            }
                                            if tips.currentTip is FollowTip{
                                                tips.currentTip?.invalidate(reason: .actionPerformed)
                                            }
                                        }label: {
                                            Image(systemName: following.contains(feed[currentIndex].creator) ? "checkmark" : "plus")
                                                .frame(width: 50, height: 50)
                                                .glassEffect(.regular.interactive())
                                        }
                                        .contentTransition(.symbolEffect(.replace))
                                        .popoverTip(tips.currentTip as? FollowTip)
                                    }
                                }
                                Button{
                                    if likedVideos.contains(feed[currentIndex]){
                                        likedVideos.removeAll(where: {$0 == feed[currentIndex]})
                                    }else{
                                        likedVideos.append(feed[currentIndex])
                                        dataManager.likedTags.formUnion(feed[currentIndex].tags)
                                        
                                    }
                                    if tips.currentTip is LikeTip{
                                        tips.currentTip?.invalidate(reason: .actionPerformed)
                                    }
                                }label: {
                                    Image(systemName: likedVideos.contains(feed[currentIndex]) ? "heart.fill" :"heart")
                                        .frame(width: 50, height: 50)
                                        .glassEffect(.regular.interactive())
                                }
                                .popoverTip(tips.currentTip as? LikeTip)
                            }
                            Spacer()
                        }
                        HStack{
                            VStack{
                                VStack{
                                    let taskValues = [
                                        "watch": lastIndex,
                                        "like": likedVideos.count,
                                        "follow": following.count
                                    ]
                                    Text("Tasks")
                                        .font(.largeTitle.bold())
                                    ForEach($dataManager.tasks, id: \.name) { $task in
                                        TaskView(task: $task, value: taskValues[task.name] ?? (task.done ? 1 : 0), lastScore: $lastScore)
                                    }
                                }
                                .frame(width: 200)
                                .padding()
                                .glassEffect(in: .rect(cornerRadius: 25))
                                Spacer()
                            }
                            Spacer()
                            VStack{
                                HStack{
                                    Image(systemName: "face.smiling")
                                    Text("\(dataManager.score)")
                                }
                                .bold()
                                .padding(10)
                                .glassEffect(.regular)
                                Text("\(lastScore>0 ? "+" : "-")\(lastScore)")
                                    .foregroundStyle(lastScore > 0 ? .green : lastScore < 0 ? .red : .clear)
                                    .onAppear(){
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                lastScore = 0
                                            }
                                        }
                                    }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }else{
                    Rectangle()
                        .onAppear(){
                            feed = Array(videos.rankedVideos(likedTags: dataManager.likedTags).prefix(3))
                            for tag in feed[currentIndex].tags{
                                if dataManager.likedTags.contains(tag){
                                    dataManager.score += 1
                                    lastScore+=1
                                }
                            }
                        }
                }
            }
        }
    }
}
extension [Video]{
    func rankedVideos(likedTags: Set<String>) -> [Video] {
        return self.map{ video in
            (video, video.tags.filter{likedTags.contains($0)}.count)
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
struct PlayingVideoView: View {
    var video: Video
    @Binding var following: Set<String>
    var body: some View {
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
                            Text("#\(tag)")
                                .bold()
                        }
                    }
                    
                }
                Spacer()
            }
            .padding(.horizontal, 50)
        }
        .foregroundStyle(.white)
        .padding()
    }
}
#Preview {
    @Previewable @State var following: Set<String> = []
    PlayingVideoView(video: Video(caption: "ok blacked out like a phantom aaaaaa", tags: ["tuff","timothy"], text: "", image: "", creator: "esdcard"), following: $following)
        .frame(width: 500)
        .background(Color.accentColor)
        .mask{
            RoundedRectangle(cornerRadius: 50)
        }
}
struct LikeTip: Tip{
    var title: Text {
        Text("Liking videos")
    }
    var message: Text? {
        Text("Click this to see more videos like this one and be able to earn more dopamine points!")
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
struct TaskView: View{
    @Binding var task: ATask
    var value: Int
    @State private var animatedValue = 0.0
    @Environment(DataManager.self) var dataManager
    @Binding var lastScore: Int
    @State private var done = false
    var body: some View{
        @Bindable var dataManager = dataManager
        if !task.done{
            ProgressView(value: animatedValue, total: Double(task.total)){
                HStack{
                    Image(systemName: task.image)
                    Text("\(task.title)")
                    Spacer()
                    Text("\(task.points)")
                    Image(systemName: "face.smiling")
                }
            }
            .tint(value >= task.total ? .green : .accentColor)
            .onChange(of: value){
                withAnimation(.easeOut) {
                    animatedValue = Double(value)
                }
                if value == task.total && !done{
                    done = true
                    dataManager.score += task.points
                    withAnimation {
                        lastScore+=task.points
                    }
                    withAnimation(.linear.delay(1)) {
                        task.done = true
                    }
                }
            }
            
        }
    }
}
struct ATask: Equatable{
    var name: String
    var title: String
    var total: Int = 1
    var image: String
    var points: Int
    var done = false
}
