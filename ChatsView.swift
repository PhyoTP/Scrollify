//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 2/1/26.
//

import SwiftUI

struct ChatsView: View {
    @Binding var chats: [Chat]
    @State private var nicknames: [String: String] = ["bobby1479":"my best friend","danielletan73":"Mom"]
    @Binding var newMessages: [(String, Message)]
    var body: some View {
        NavigationStack {
            List($chats, id: \.user) { $chat in
                NavigationLink(destination: ChatView(chat: $chat, newMessages: $newMessages)) {
                    HStack{
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(Color.accentColor)
                            .font(.system(size: 50))
                        VStack(alignment: .leading){
                            Text(chat.user + (nicknames[chat.user] != nil ? " (\(nicknames[chat.user]!))" : ""))
                                .font(.title)
                                .bold()
                            Text(chat.messages.last != nil ? (chat.messages.last!.isMe ? "You: \(chat.messages.last!.text)" : "\(chat.user): \(chat.messages.last!.text)") : "No messages")
                        }
                        Spacer()
                        let count = newMessages.count(where: {$0.0 == chat.user})
                        if count != 0{
                            Text(String(count))
                                .padding()
                                .background(.red)
                                .mask(Circle())
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                                .font(.title2)
                        }
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}
let lastMessageForPreview = Message(isMe: false, text: "Son")
#Preview {
    @Previewable @State var chats: [Chat] = [
        Chat(user: "bobby1479", messages: [
            Message(isMe: true, text: "wsg"),
            Message(isMe: false, text: "hii"),
            Message(isMe: true, text: "how you doin"),
            Message(isMe: false, text: "fine hbu"),
            Message(isMe: true, text: "pretty chill")
        ]),
        Chat(user: "danielletan73", messages: [lastMessageForPreview])
    ]
    @Previewable @State var newMessages: [(String, Message)] = [("danielletan79", lastMessageForPreview)]
    ChatsView(chats: $chats, newMessages: $newMessages)
        .preferredColorScheme(.dark)
}
struct ChatView: View {
    @Binding var chat: Chat
    @Binding var newMessages: [(String, Message)]
    @State private var localNewMessages = [(String, Message)]()
    @State private var typing = false
    @AppStorage("hasStore") var store = false
    var body: some View {
        NavigationStack{
            VStack{
                ScrollViewReader{ proxy in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading){
                            if chat.messages.isEmpty{
                                Text("No messages")
                                    .foregroundStyle(Color.secondary)
                                    .font(.title.bold())
                            }
                            ForEach(chat.messages){message in
                                if let first = localNewMessages.first(where: {chat.messages.contains($0.1)}), message.id == first.1.id{
                                    ZStack{
                                        Divider()
                                        Text("New messages")
                                            .padding()
                                            .background()
                                    }
                                    .foregroundStyle(Color.accentColor)
                                }
                                HStack{
                                    if message.isMe{
                                        Spacer()
                                    }
                                    Text(message.text)
                                        .padding()
                                        .background(message.isMe ? Color.accentColor : .secondary)
                                        .foregroundStyle(.white)
                                        .mask(RoundedRectangle(cornerRadius: 20))
                                    if !message.isMe{
                                        Spacer()
                                    }
                                }
                            }
                            if typing{
                                HStack{
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.title2)
                                    Text("Typing...")
                                        .foregroundStyle(.secondary)
                                        .font(.title2.weight(.medium))
                                }
                                .onDisappear(){
                                    proxy.scrollTo("bottom")
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding()
                        .navigationTitle(chat.user)
                        .onAppear(){
                            localNewMessages = newMessages.filter({$0.0 == chat.user})
                            newMessages.removeAll(where: {$0.0 == chat.user})
                        }
                    }
                    .onAppear(){
                        proxy.scrollTo("bottom")
                    }
                }
                if let lastText = chat.messages.last?.text{
                    switch chat.user{
                    case "bobby1479":
                        switch lastText{
                        case "yo bro":
                            TextButton(text: "What's up", messages: $chat.messages, typing: $typing, next: ["you wanna go bowling with us later?"])
                            
                        case "you wanna go bowling with us later?":
                            HStack{
                                TextButton(text: "sure", messages: $chat.messages, typing: $typing, next: ["alr then see you in 30"])
                                TextButton(text: "nah I'm busy", messages: $chat.messages, typing: $typing, next: ["oh alr then"])
                            }
                        case "bro u here yet":
                            TextButton(text: "oh shoot sorry i forgot", messages: $chat.messages, typing: $typing, next: ["dude are you serious","you never hang out with us anymore"])
                        case "you never hang out with us anymore":
                            HStack{
                                TextButton(text: "sorry", messages: $chat.messages, typing: $typing, next: ["you're always on your phone"])
                                TextButton(text: "I'm just really busy", messages: $chat.messages, typing: $typing, next: ["that's what you always say"])
                            }
                        default:
                            Color.clear
                                .frame(height: 1)
                                .onChange(of: chat.messages) { oldValue, newValue in
                                    if newValue.count == 16 {
                                        store = true
                                    }
                                }
                        }
                    case "danielletan73":
                        switch lastText{
                        case "Son":
                            TextButton(text: "Yes?", messages: $chat.messages, typing: $typing, next: ["I just got your exam results", "They've been getting worse and worse", "You're always on the phone", "I never see you study", "I think it's time for you to stop"])
                        default:
                            Color.clear
                                .frame(height: 1)
                                .onChange(of: chat.messages) { oldValue, newValue in
                                    if newValue.count == 7 {
                                        store = true
                                    }
                                }
                        }
                    default:
                        EmptyView()
                    }
                    
                }
            }
        }
    }
}
struct TextButton: View {
    var text: String
    @Binding var messages: [Message]
    @Binding var typing: Bool
    var next: [String]
    var body: some View {
        Button(text){
            messages.append(Message(isMe: true, text: text))
            for i in next.indices {
                typing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(2 * i + 2)) {
                    typing = false
                    messages.append(Message(isMe: false, text: next[i]))
                    if i != next.count - 1 {
                        typing = true
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular.tint(Color.accentColor))
        .padding()
        .foregroundStyle(.white)
    }
}
