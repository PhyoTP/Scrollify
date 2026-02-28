import SwiftUI
import FoundationModels
import TipKit

let tags: Set<String> = ["animals","news","learning","entertainment","food","podcasts","fitness","funny","gaming","reaction","sports","cars","health","dance","fashion","tech"]

struct ContentView: View {
    @State private var done = false
    @State private var scale: CGFloat = 1.0
    @Environment(DataManager.self) var dataManager
    @State private var zoomOut = true
    @State private var endingText = ""
    @State private var opacity = 1.0
    @State private var back = false
    @State private var showCompleteAlert = false
    var body: some View {
        @Bindable var dataManager = dataManager
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
                        AppView()
                            .mask{
                                RoundedRectangle(cornerRadius: 30)
                                    .ignoresSafeArea()
                            }
                            .scaleEffect(scale)
                            .onChange(of: dataManager.autoscroll) { oldValue, newValue in
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
                            .onChange(of: dataManager.doneScreentime) { oldValue, newValue in
                                if newValue{
                                    zoomOut = false
                                    withAnimation(.linear(duration: 5)) {
                                        scale = 0.5
                                    }
                                    withAnimation(.linear.delay(5)) {
                                        endingText = "The Good Ending"
                                    }
                                    withAnimation(.linear.delay(10)) {
                                        opacity = 0.0
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
                    dataManager.chats = [
                        Chat(user: "bobby1479", messages: [
                            Message(isMe: true, text: "wsg"),
                            Message(isMe: false, text: "hii"),
                            Message(isMe: true, text: "how you doin"),
                            Message(isMe: false, text: "fine hbu"),
                            Message(isMe: true, text: "pretty chill")
                        ]),
                        Chat(user: "danielletan73", messages: [])
                    ]
                    if dataManager.endings.isEmpty{
                        showCompleteAlert = true
                    }
                    if dataManager.screentime{
                        if let bowl = dataManager.tasks.first(where: { $0.name == "bowlingmain"}), bowl.done{
                            dataManager.endings.insert("bowl")
                        }else if let study = dataManager.tasks.first(where: { $0.name == "study"}), study.done{
                            dataManager.endings.insert("study")
                        }else{
                            dataManager.endings.insert("sorry")
                        }
                    }else{
                        dataManager.endings.insert("bad")
                    }
                    dataManager.tasks.removeAll(where: {["bowlingmain","bowlingmeet","study"].contains($0.name)})
                    dataManager.screentime = false
                    dataManager.doneScreentime = false
                    dataManager.tabSelection = "achievements"
                    dataManager.newMessages.removeAll()
                    back = false
                    
                }
            }
            .alert("You completed a storyline!", isPresented: $showCompleteAlert, actions: {}) {
                Text("Play again to find more endings")
            }
        }else{
            WelcomeView(done: $done)
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
    @Binding var done: Bool
    @State private var next = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @Environment(DataManager.self) var dataManager
    var body: some View {
        @Bindable var dataManager = dataManager
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
                        Button{
                            withAnimation {
                                if dataManager.likedTags.contains(tag){
                                    dataManager.likedTags.remove(tag)
                                }else{
                                    dataManager.likedTags.insert(tag)
                                }
                            }
                        }label:{
                            Text(tag.capitalized)
                                .bold()
                                .padding(10)
                                .glassEffect(dataManager.likedTags.contains(tag) ? .regular.tint(.accentColor) : .regular)
                                .foregroundStyle(.white)
                                .padding(5)
                        }
                        
                    }
                }
                .padding()
                Button{
                    withAnimation {
                        next = true
                    }
                }label: {
                    Text(dataManager.likedTags.count >= 3 ? "Next" : "Choose at least 3")
                        .padding()
                        .background(dataManager.likedTags.count < 3 ? Color.gray:Color.accentColor)
                        .foregroundStyle(.white)
                        .bold()
                        .mask{
                            RoundedRectangle(cornerRadius: 10)
                        }
                }
                .disabled(dataManager.likedTags.count < 3)
            }else{
                IntroView(image: "apple.intelligence", title: "Generated Content", description: "Scrollify gauges the types of videos you are interested in and uses Foundation Models to generate content you might like.")
                IntroView(image: "face.smiling", title: "Dopamine Points", description: "Whenever you see a video that matches your interests, you will get dopamine points based on how much your previous interests overlap.")
                IntroView(image: "heart", title: "Liking", description: "Like a video to see more posts like it. Liking it also gives you more points when a video similar to it appears.")
                ActionButton("Start"){
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
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 2:
                Text("Social media addiction isn't something new. However, short-form video platforms have made it even more addictive.")
                IntroView(image: "play.square.stack.fill", title: "Social Media Algorithms", description: "Give you a calculated, never-ending stream of posts you are guaranteed to like, making it especially hard to put down your device.", custom: true)
                IntroView(image: "chart.pie.fill", title: "Teenage Addiction", description: "One in two teenagers report feeling “addicted” to social media.", custom: true)
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 3:
                Text("Social media addiction comes with many drawbacks. It causes you to spend less time:")
                IntroView(image: "person.3.fill", title: "With people who matter", description: "Family, friends, relationships that aren't parasocial", custom: true)
                IntroView(image: "chart.pie.fill", title: "Doing things that matter", description: "Work, passions, things that are productive", custom: true)
                IntroView(image: "person.crop.circle.fill", title: "For yourself", description: "Exercising, reflecting, giving yourself a true break", custom: true)
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 5:
                Text("Excessive screen time can lead to:")
                IntroView(image: "eye.trianglebadge.exclamationmark.fill", title: "Eye strain", description: "Constantly staring at a screen is bad for your eyes and can lead to things like headaches and blurred vision.", custom: true)
                IntroView(image: "bed.double.fill", title: "Sleep deprivation", description: "When you scroll at night, the bright light from your phone makes it harder to sleep.", custom: true)
                IntroView(image: "brain.fill", title: "Decreased attention span", description: "The short-form nature of the videos where creators try to fit as much content as possible causes you to not be able to concentrate as well on other things.", custom: true)
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 4:
                Text("I used to be addicted to social media too. Some of the symptoms include, but are not limited to:")
                IntroView(image: "iphone.and.arrow.right.inward", title: "Opening the app instinctively", description: "Unconsicously opening the app whenever you have time (or don't)", custom: true)
                IntroView(image: "arrow.turn.up.forward.iphone.fill", title: "Reopening the app", description: "Going back to the app right when you close it, sometimes repeatedly", custom: true)
                IntroView(image: "clock.fill", title: "Spending more time than you want to on it", description: "Thinking to yourself 'I'll just watch for a few minutes', then hours pass", custom: true)
                IntroView(image: "brain.fill", title: "Thinking about it all the time", description: "Not being able to concentrate on anything else", custom: true)
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 6:
                Text("Don’t get me wrong – I'm not saying we should stop using social media entirely – it definitely has its benefits. But it's easy to get into the wrong corners of the internet.")
                IntroView(image: "exclamationmark.triangle.text.page.fill", title: "Fake news", description: "Misinformation meant to mislead people into thinking it's real", custom: true)
                IntroView(image: "person.badge.shield.exclamationmark.fill", title: "Hate speech", description: "Videos or posts that spread hatred or discrimination against any group of people", custom: true)
                IntroView(image: "person.crop.circle.dashed", title: "Echo chambers", description: "The algorithm feeds your beliefs, making you engage more with the content, in a never-ending feedback loop", custom: true)
                ActionButton("Next"){
                    withAnimation {
                        page += 1
                    }
                }
            case 7:
                Text("If you think you’re addicted, here are some ways to stop:")
                IntroView(image: "hourglass", title: "Set screen time limits", description: "Even better if you can get someone else to set a passcode (parents, relatives, friends)", custom: true)
                IntroView(image: "powersleep", title: "Have a downtime", description: "So that you don't do it as the first or last thing you do in a day", custom: true)
                IntroView(image: "trash.fill", title: "Delete the app entirely", description: "Works surprisingly well, from personal experience", custom: true)
                ActionButton("Complete"){
                    back = true
                }
            default:
                Text("wait im not done with this yet")
                    .onAppear(){
                        back = true
                    }
            }
        }
        .font(.custom("Chalkduster", size: 18))
        .frame(maxWidth: 400)
    }
}
//#Preview {
//    @Previewable @State var back = false
//    EndingView(back: $back)
//        .preferredColorScheme(.dark)
//}
//extension Button{
//    func actionButton() -> some View {
//        self
//            .padding()
//            .background(Color.accentColor)
//            .foregroundStyle(.white)
//            .bold()
//            .mask{
//                RoundedRectangle(cornerRadius: 10)
//            }
//    }
//}
struct ActionButton: View{
    var name: String
    var action: () -> Void
    init(_ name: String, action: @escaping () -> Void) {
        self.name = name
        self.action = action
    }
    var body: some View{
        Button(action: action){
            Text(name)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .bold()
                .mask{
                    RoundedRectangle(cornerRadius: 10)
                }
        }
    }
}
