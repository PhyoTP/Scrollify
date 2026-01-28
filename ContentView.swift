import SwiftUI
import FoundationModels
import TipKit

let tags: Set<String> = ["animals","news","learning","entertainment","food","podcasts","fitness","funny","gaming","reaction","sports","cars","health","dance","fashion","tech"]

struct ContentView: View {
    @State private var likedTags: Set<String> = []
    @State private var done = false
    @State private var scale: CGFloat = 1.0
    @AppStorage("autoscroll") var autoscroll = false
    @State private var zoomOut = true
    @State private var endingText = ""
    @State private var opacity = 1.0
    @State private var back = false
    @State private var tabSelection = "feed"
    var body: some View {
        if done {
            Group{
                if opacity == 1.0{
                    ZStack{
                        Color(red: 52/255, green: 52/255, blue: 52/255)
                            .mask{
                                RoundedRectangle(cornerRadius: 35)
                                    .ignoresSafeArea()
                            }
                            .shadow(color: .white, radius: 100)
                            .scaleEffect(scale*1.01)
                        AppView(tabSelection: $tabSelection, likedTags: $likedTags, back: back)
                            .mask{
                                RoundedRectangle(cornerRadius: 30)
                                    .ignoresSafeArea()
                            }
                            .scaleEffect(scale)
                            .onChange(of: autoscroll) { oldValue, newValue in
                                //                        .onAppear(){
                                if newValue{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        zoomOut = false
                                        withAnimation(.linear(duration: 15)) {
                                            scale = 0.5
                                        }
                                        withAnimation(.linear.delay(15)) {
                                            endingText = "The Bad Ending"
                                        }
                                        withAnimation(.linear.delay(20)) {
                                            opacity = 0.0
                                        }
                                    }
                                }
                            }
                            .allowsHitTesting(zoomOut)
                        if !endingText.isEmpty{
                            Text(endingText)
                                .font(.custom("HelveticaNeue-bold", size: 100))
                        }
                    }
                } else {
                    EndingView(back: $back)
                }
            }
            .onChange(of: back) {
                if back{
                    opacity = 1.0
                    endingText = ""
                    zoomOut = true
                    scale = 1.0
                    tabSelection = "screentime"
                }
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
    @State private var next = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @AppStorage("autoscroll") var autoscroll = false
    @AppStorage("hasStore") var store = false
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
                        .foregroundStyle(.white)
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
                    store = false
                    autoscroll = false
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
                .actionButton()
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
    var custom = false
    var body: some View {
        HStack{
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(10)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading){
                if custom{
                    Text(title)
                        .font(.custom("HelveticaNeue-bold", size: 21))
                }else{
                    Text(title)
                        .bold()
                }
                Text(description)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
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
    @Binding var tabSelection: String
    @AppStorage("hasStore") var store = false
    @State private var storeAlert = false
    @State private var score = 0
    @AppStorage("autoscroll") var autoscroll = false
    @Binding var likedTags: Set<String>
    @State private var autoscrollAlert = false
    var back: Bool
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
            if back{
                Tab(value: "screentime"){
                    ScreenTimeView()
                }label: {
                    Label("Screen Time", image: "hourglass")
                }
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
        .onChange(of: store) {
            if store{
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
        .onChange(of: autoscroll) {
            print("auto changed")
            if autoscroll{
                print("auto true")
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
struct EndingView: View {
    @State private var page = 1
    @Binding var back: Bool
    var body: some View {
        VStack{
            switch page{
            case 1:
                Text("Social media is more widespread than ever. ")
                IntroView(image: "chart.pie.fill", title: "Global Users", description: "Over 4.7 billion people worldwide are active social media users.", custom: true)
                IntroView(image: "chart.dots.scatter", title: "Average Usage", description: "The average person spends around 2 hours per day on social media globally.", custom: true)
                Text("This is especially true amongst teenagers, where:")
                IntroView(image: "chart.bar.xaxis", title: "In the US", description: "Teens often exceed 3–4+ hours per day. ", custom: true)
                Text("That’s about the same as a full day’s worth of time every week.")
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 2:
                Text("Social media addiction isn't something new. However, short-form video platforms have made it even more addictive.")
                IntroView(image: "play.square.stack.fill", title: "Social Media Algorithms", description: "Give you a calculated, never-ending stream of posts you are guaranteed to like, making it especially hard to put down your device.", custom: true)
                IntroView(image: "chart.pie.fill", title: "Teenage Addiction", description: "One in two teenagers report feeling “addicted” to social media.", custom: true)
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 3:
                Text("Social media addiction comes with many drawbacks. It causes you to spend less time:")
                IntroView(image: "person.3.fill", title: "With people who matter", description: "Family, friends, relationships that aren't parasocial", custom: true)
                IntroView(image: "chart.pie.fill", title: "Doing things that matter", description: "Work, passions, things that are productive", custom: true)
                IntroView(image: "person.crop.circle.fill", title: "For yourself", description: "Exercising, reflecting, giving yourself a true break", custom: true)
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 5:
                Text("Excessive screen time can lead to:")
                IntroView(image: "eye.trianglebadge.exclamationmark.fill", title: "Eye strain", description: "Constantly staring at a screen is bad for your eyes and can lead to things like headaches and blurred vision.", custom: true)
                IntroView(image: "bed.double.fill", title: "Sleep deprivation", description: "When you scroll at night, the bright light from your phone makes it harder to sleep.", custom: true)
                IntroView(image: "brain.fill", title: "Decreased attention span", description: "The short-form nature of the videos where creators try to fit as much content as possible causes you to not be able to concentrate as well on other things.", custom: true)
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 4:
                Text("I used to be addicted to social media too. Some of the symptoms include, but are not limited to:")
                IntroView(image: "iphone.and.arrow.right.inward", title: "Opening the app instinctively", description: "Unconsicously opening the app whenever you have time (or don't)", custom: true)
                IntroView(image: "arrow.turn.up.forward.iphone.fill", title: "Reopening the app", description: "Going back to the app right when you close it, sometimes repeatedly", custom: true)
                IntroView(image: "clock.fill", title: "Spending more time than you want to on it", description: "Thinking to yourself 'I'll just watch for a few minutes', then hours pass", custom: true)
                IntroView(image: "brain.fill", title: "Thinking about it all the time", description: "Not being able to concentrate on anything else", custom: true)
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 6:
                Text("Don’t get me wrong – I'm not saying we should stop using social media entirely – it definitely has its benefits. But it's easy to get into the wrong corners of the internet.")
                IntroView(image: "exclamationmark.triangle.text.page.fill", title: "Fake news", description: "Misinformation meant to mislead people into thinking it's real", custom: true)
                IntroView(image: "person.badge.shield.exclamationmark.fill", title: "Hate speech", description: "Videos or posts that spread hatred or discrimination against any group of people", custom: true)
                IntroView(image: "person.crop.circle.dashed", title: "Echo chambers", description: "The algorithm feeds your beliefs, making you engage more with the content, in a never-ending feedback loop", custom: true)
                Button("Next"){
                    withAnimation {
                        page += 1
                    }
                }
                .actionButton()
            case 7:
                Text("If you think you’re addicted, here are some ways to stop:")
                IntroView(image: "hourglass", title: "Set screen time limits", description: "Even better if you can get someone else to set a passcode (parents, relatives, friends)", custom: true)
                IntroView(image: "powersleep", title: "Have a downtime", description: "So that you don't do it as the first or last thing you do in a day", custom: true)
                IntroView(image: "trash.fill", title: "Delete the app entirely", description: "Works surprisingly well, from personal experience", custom: true)
                Button("Go to Screen Time"){
                    back = true
                }
                .actionButton()
            default:
                Text("wait im not done with this yet")
            }
        }
        .font(.custom("Chalkduster", size: 18))
        .frame(maxWidth: 400)
    }
}
//#Preview {
//    EndingView()
//        .preferredColorScheme(.dark)
//}
extension Button{
    func actionButton() -> some View {
        self
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .bold()
            .mask{
                RoundedRectangle(cornerRadius: 10)
            }
    }
}
