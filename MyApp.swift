import SwiftUI
import TipKit
@Observable class DataManager{
    var store = false
    var autoscroll = false
    var bowling = false
    var chats: [Chat] = [
        Chat(user: "bobby1479", messages: [
            Message(isMe: true, text: "wsg"),
            Message(isMe: false, text: "hii"),
            Message(isMe: true, text: "how you doin"),
            Message(isMe: false, text: "fine hbu"),
            Message(isMe: true, text: "pretty chill")
        ]),
        Chat(user: "danielletan73", messages: [])
    ]
    var score = 0
    var newMessages: [(String, Message)] = []
    var likedTags: Set<String> = []
    var tasks: [ATask] = [
        ATask(name: "watch", title: "Watch 10 videos", total: 10, image: "eye", points: 5),
        ATask(name: "like", title: "Like 5 videos", total: 5, image: "heart", points: 5),
        ATask(name: "follow", title: "Follow 5 creators", total: 5, image: "person.badge.plus", points: 10)
    ]
}
@main
struct MyApp: App {
    @State var dataManager = DataManager()
    init() {
        try? Tips.configure()
        try? Tips.resetDatastore()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(dataManager)
        }
    }
}
