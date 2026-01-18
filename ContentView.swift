import SwiftUI
import FoundationModels

let tags: Set<String> = ["animals","news","learning","entertainment","food","podcasts","fitness","funny","gaming","reaction","sports","cars","health","dance","fashion","tech"]

struct ContentView: View {
    @State private var likedTags: Set<String> = []
    @State private var done = false
    @State private var scale: CGFloat = 1.0
    @AppStorage("autoscroll") var autoscroll = false
    @State private var zoomOut = true
    var body: some View {
        if done {
            ZStack{
                Color(red: 52/255, green: 52/255, blue: 52/255)
                    .ignoresSafeArea()
                    .mask{
                        RoundedRectangle(cornerRadius: 35)
                            .ignoresSafeArea()
                    }
                    .shadow(color: .white, radius: 100)
                    .scaleEffect(scale*1.01)
                AppView(likedTags: $likedTags)
                    .mask{
                        RoundedRectangle(cornerRadius: 30)
                            .ignoresSafeArea()
                    }
                    .scaleEffect(scale)
                    .onChange(of: autoscroll) { oldValue, newValue in
                        if newValue{
                            zoomOut = false
                            withAnimation(.linear(duration: 30)) {
                                scale = 0.5
                            }
                        }
                    }
                    .allowsHitTesting(zoomOut)
            }
            
        }else{
            WelcomeView(likedTags: $likedTags, done: $done)
                .frame(maxWidth: 400)
            
        }
    }
}
extension Text{
    func header() -> some View{
        self
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
    }
}
struct WelcomeView: View {
    @Binding var likedTags: Set<String>
    @Binding var done: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var next = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    var body: some View {
        VStack{
            Text("Welcome to Scrollify")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.accentColor)
            Text("An app that simulates a feed of short-form videos")
            if !next{
                Text("Start by choosing genres you are interested in:")
                    .bold()
                FlowLayout{
                    ForEach(Array(tags), id: \.self){tag in
                        Button(tag.capitalized){
                            withAnimation {
                                if likedTags.contains(tag){
                                    likedTags.remove(tag)
                                }else{
                                    likedTags.insert(tag)
                                }
                            }
                        }
                        .bold()
                        .padding(10)
                        .glassEffect(likedTags.contains(tag) ? .regular.tint(.accentColor) : .regular)
                        .foregroundStyle(colorScheme == .light && !likedTags.contains(tag) ? .black : .white)
                        .padding(5)
                        
                    }
                }
                .padding()
                Button(likedTags.count >= 3 ? "Next" : "Choose at least 3"){
                    withAnimation {
                        next = true
                    }
                }
                .padding()
                .background(likedTags.count < 3 ? Color.gray:Color.accentColor)
                .foregroundStyle(.white)
                .bold()
                .mask{
                    RoundedRectangle(cornerRadius: 10)
                }
                .disabled(likedTags.count < 3)
            }else{
                IntroView(image: "apple.intelligence", title: "Generated Content", description: "Scrollify gauges the types of videos you are interested in and uses Foundation Models to generate content you might like.")
                IntroView(image: "face.smiling", title: "Dopamine Points", description: "Whenever you see a video that matches your interests, you will get dopamine points based on how much your previous interests overlap.")
                IntroView(image: "heart", title: "Liking", description: "Like a video to see more posts like it. Liking it also gives you more points when a video similar to it appears.")
                Button("Start"){
                    done = true
                    let model = SystemLanguageModel.default
                    switch model.availability {
                    case .available:
                        print("The on-device foundation model is available and ready to use.")
                    case .unavailable(let reason):
                        showAlert = true
                        switch reason {
                        case .appleIntelligenceNotEnabled:
                            alertMessage = "Apple Intelligence is not enabled."
                        case .deviceNotEligible:
                            alertMessage = "This device is not eligible for Apple Intelligence."
                        case .modelNotReady:
                            alertMessage = "The language model is not ready yet (e.g., still downloading)."
                        @unknown default:
                            alertMessage = "The model is unavailable for an unknown reason."
                        }
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .bold()
                .mask{
                    RoundedRectangle(cornerRadius: 10)
                }
                .alert(alertMessage, isPresented: $showAlert) {} message: {
                    Text("Apple Intelligence is recommended for the best experience.")
                }
            }
        }
    }
}
struct IntroView: View {
    var image: String
    var title: String
    var description: String
    var body: some View {
        HStack{
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(10)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                Text(description)
            }
        }
    }
}
struct FlowLayout: Layout{
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width = 0.0
        var height = 0.0
        var rowHeight = 0.0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if width + size.width > maxWidth{
                height += rowHeight
                width = 0
                rowHeight = 0.0
            }
            width += size.width
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight = 0.0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y),
                       proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width
            rowHeight = max(rowHeight, size.height)
        }
    }
}
struct AppView: View{
    @State private var videos = premadeVideos
    @State private var showSheet = true
    @State private var query = ""
    @State private var following: Set<String> = []
    @State private var chats: [Chat] = [
        Chat(user: "bobby1479", messages: [
            Message(isMe: true, text: "wsg"),
            Message(isMe: false, text: "hii"),
            Message(isMe: true, text: "how you doin"),
            Message(isMe: false, text: "fine hbu"),
            Message(isMe: true, text: "pretty chill")
        ]),
        Chat(user: "danielletan73", messages: [])
    ]
    @State private var newMessages: [(String, Message)] = []
    @State private var newMessageAlert = false
    @State private var tabSelection = "feed"
    @AppStorage("hasStore") var store = false
    @State private var storeAlert = false
    @State private var score = 0
    @AppStorage("autoscroll") var autoscroll = false
    @Binding var likedTags: Set<String>
    @State private var autoscrollAlert = false
    var body: some View{
        TabView(selection: $tabSelection){
            Tab(value: "feed"){
                FeedView(likedTags: $likedTags, videos: $videos, score: $score, following: $following, chats: $chats)
            } label: {
                Label("Feed", systemImage: "square.stack")
            }
            Tab(value: "chats") {
                ChatsView(chats: $chats, newMessages: $newMessages)
            } label: {
                Label("Chats", systemImage: "bubble.left.and.bubble.right")
            }
            .badge(newMessages.count)
            if store{
                Tab(value: "store"){
                    StoreView(score: $score)
                }label: {
                    Label("Store", systemImage: "storefront")
                }
            }
            Tab(value: "debug"){ // MUST DELETE
                Toggle("has store", isOn: $store)
                Toggle("has autoscroll", isOn: $autoscroll)
                
            }label: {
                Label("Debug", systemImage: "arrow.2.circlepath.circle")
            }
            Tab(value: "search", role: .search) {
                
                NavigationStack{
                    if query.isEmpty{
                        VStack{
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                            Text("Search for videos, creators, tags...")
                                .font(.title)
                        }
                        .foregroundStyle(.gray)
                    }else{
                        ScrollView(.vertical){
                            
                            VStack{
                                Text("Creators").header()
                                let filteredCreators = Set(videos.compactMap(\.creator)).sorted().filter{$0.lowercased().contains(query.lowercased())}
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                                    ForEach(filteredCreators, id: \.self){creator in
                                        NavigationLink{
                                            ProfileView(videos: videos, name: creator, following: $following)
                                        }label:{
                                            HStack{
                                                Label(creator, systemImage: "person.crop.circle")
                                                    .padding()
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(.quaternary)
                                            .mask{
                                                RoundedRectangle(cornerRadius: 10)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                Text("Videos").header()
                                let filteredVideos = videos.filter{$0.caption.lowercased().contains(query.lowercased())||$0.text.lowercased().contains(query.lowercased())}
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                                    ForEach(filteredVideos){video in
                                        NavigationLink{
                                            PlayingVideoView(video: video, following: $following)
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
                        .padding()
                    }
                }
                
                .searchable(text: $query)
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
        .onChange(of: chats) { oldValue, newValue in
            for i in newValue.indices{
                if oldValue[i].messages.count != newValue[i].messages.count{
                    if newValue[i].messages[oldValue[i].messages.count...].contains(where: {$0.isMe == true}){
                        newMessages.removeAll(where: {$0.0 == newValue[i].user})
                    }else{
                        newMessages.append(contentsOf: newValue[i].messages[oldValue[i].messages.count...].map{(newValue[i].user, $0)})
                    }
                    if tabSelection != "chats"{
                        newMessageAlert = true
                    }
                }
            }
            
        }
        .alert("New message", isPresented: $newMessageAlert) {
            Button("Go to chats"){
                tabSelection = "chats"
            }
        } message: {
            if let lastMessage = newMessages.last{
                Text(lastMessage.0 + ": " + lastMessage.1.text)
            }
        }
        .onChange(of: store) { oldValue, newValue in
            if newValue{
                storeAlert = true
            }
        }
        .alert("New feature!", isPresented: $storeAlert) {
            Button("Go to store"){
                tabSelection = "store"
            }
        } message: {
            Text("Store has been added! Spend your dopamine points on cool new items!")
        }
        .onChange(of: autoscroll) { oldValue, newValue in
            if newValue{
                autoscrollAlert = true
            }
        }
        .alert("Autoscroll unlocked!", isPresented: $autoscrollAlert) {
            Button("Go to feed"){
                tabSelection = "feed"
            }
        } message: {
            Text("You have unlocked autoscrolling, try it out now!")
        }
    }
}
