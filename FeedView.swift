import SwiftUI
import FoundationModels

struct FeedView: View {
    @State private var currentIndex = 0
    @State private var currentOffset: CGFloat = 0
    @State private var likedVideos: [Video] = []
    @State private var feed: [Video] = []
    @Binding var likedTags: Set<String>
    @Binding var videos: [Video]
    @State private var lastIndex = 0
    @Binding var score: Int
    @State private var lastScore = 0
    @Binding var following: Set<String>
    @Binding var chats: [Chat]
    @AppStorage("autoscroll") var autoscroll = false
    @State private var isAutoscrolling = false
    @State private var timer: Timer?
    @State private var lastAutoscroll = false
    var body: some View {
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
                                }
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular)
                                if autoscroll{
                                    Button{
                                        isAutoscrolling.toggle()
                                    }label: {
                                        Image(systemName: isAutoscrolling ? "pause.fill" : "play.fill")
                                    }
                                    .contentTransition(.symbolEffect(.replace))
                                    .frame(width: 50, height: 50)
                                    .glassEffect(.regular)
                                    .onChange(of: isAutoscrolling) { oldValue, newValue in
                                        if newValue{
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
                                        if autoscroll && !lastAutoscroll{
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
                                }
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular)
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
                                    .onChange(of: currentIndex) { oldValue, newValue in
                                        if newValue + 1 >= feed.count{
                                            if let nextVideo = videos.rankedVideos(likedTags: likedTags).filter({!feed.contains($0)}).first{
                                                feed.append(nextVideo)
                                            }else{
                                                print("touch grass")
                                            }
                                        }
                                        if newValue>lastIndex{
                                            lastIndex = newValue
                                            lastScore = 0
                                            for tag in feed[currentIndex].tags{
                                                if likedTags.subtracting(additionalTags).contains(tag){
                                                    score += 1
                                                    withAnimation {
                                                        lastScore+=1
                                                    }
                                                }
                                            }
                                            Task{
                                                do{
                                                    let video = try await generateVideo(likedTags: likedTags, creators: following, allVideos: videos)
                                                    feed.append(video)
                                                    videos.append(video)
                                                }catch{
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            if let friendIndex = chats.firstIndex(where: {$0.user == "bobby1479"}), let momIndex = chats.firstIndex(where: {$0.user == "danielletan73"}){
                                                if lastIndex == 10{
                                                    chats[friendIndex].messages.append(Message(isMe: false, text: "yo bro"))
                                                }else if lastIndex == 20{
                                                    if chats[friendIndex].messages.last?.text == "alr then see you in 30"{
                                                        chats[friendIndex].messages.append(Message(isMe: false, text: "bro u here yet"))
                                                    }else{
                                                        chats[momIndex].messages.append(Message(isMe: false, text: "Son"))
                                                    }
                                                }
                                            }
                                        }
                                        withAnimation {
                                            proxy.scrollTo(newValue)
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
                                VStack{
                                    NavigationLink{
                                        ProfileView(videos: videos, name: feed[currentIndex].creator, following: $following)
                                    }label: {
                                        Image(systemName: "person.crop.circle")
                                    }
                                    .frame(width: 50, height: 50)
                                    .glassEffect(.clear)
                                    Button{
                                        if following.contains(feed[currentIndex].creator){
                                            following.remove(feed[currentIndex].creator)
                                        }else{
                                            following.insert(feed[currentIndex].creator)
                                        }
                                    }label: {
                                        Image(systemName: following.contains(feed[currentIndex].creator) ? "checkmark" : "plus")
                                    }
                                    .frame(width: 50, height: 50)
                                    .glassEffect(.clear)
                                    .contentTransition(.symbolEffect(.replace))
                                }
                                .glassEffect()
                                Button{
                                    if likedVideos.contains(feed[currentIndex]){
                                        likedVideos.removeAll(where: {$0 == feed[currentIndex]})
                                    }else{
                                        likedVideos.append(feed[currentIndex])
                                        likedTags.formUnion(feed[currentIndex].tags)
                                    }
                                }label: {
                                    Image(systemName: likedVideos.contains(feed[currentIndex]) ? "heart.fill" :"heart")
                                }
                                .frame(width: 50, height: 50)
                                .glassEffect(.regular)
                            }
                            Spacer()
                        }
                        HStack{
                            Spacer()
                            VStack{
                                HStack{
                                    Image(systemName: "face.smiling")
                                    Text("\(score)")
                                }
                                .bold()
                                .padding(10)
                                .glassEffect(.regular)
                                .padding(.horizontal)
                                if lastScore != 0{
                                    Text("+\(lastScore)")
                                        .foregroundStyle(.green)
                                        .onAppear(){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    lastScore = 0
                                                }
                                            }
                                        }
                                }
                                Spacer()
                            }
                        }
                    }
                }else{
                    Rectangle()
                        .onAppear(){
                            feed = Array(videos.rankedVideos(likedTags: likedTags).prefix(3))
                            for tag in feed[currentIndex].tags{
                                if likedTags.contains(tag){
                                    score += 1
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
