//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 9/2/26.
//

import SwiftUI
struct Equation: Identifiable, Equatable{
    var id = UUID()
    var first = Int.random(in: 1..<10)
    var second = Int.random(in: 1..<10)
    var sign = Int.random(in: 1...4)
    var answer: Int{
        switch sign{
        case 1: return first + second
        case 2: return first > second ? first - second : second - first
        case 3: return first * second
        default: return second
        }
    }
    var expression: String{
        switch sign{
        case 1: return "\(first) + \(second)"
        case 2: return first > second ? "\(first) - \(second)" : "\(second) - \(first)"
        case 3: return "\(first) × \(second)"
        default : return "\(first*second) / \(first)"
        }
    }
}
struct StudyView: View {
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var know = 0
    @State private var elements = [Equation()]
    @State private var value = ""
    @FocusState private var focusedField: UUID?
    @Environment(\.dismiss) var dismiss
    @Environment(DataManager.self) var dataManager
    @State private var timeCount = 0
    @State private var alertText = ""
    @State private var showAlert = false
    var body: some View {
        ZStack{
            Color.accentColor
            VStack{
                ZStack{
                    Rectangle()
                        .foregroundStyle(.white)
                    VStack{
                        Text("Score: \(know)")
                            .font(.custom("HelveticaNeue-bold", size: 30))
                        if know == 0{
                            Text("Answer the math equations")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20))
                        }
                    }
                    .foregroundStyle(Color.accentColor)
                        .padding()
                }
                .mask(RoundedRectangle(cornerRadius: 25))
                .frame(width: 300, height: 100)
                .padding()
                ZStack(alignment: .bottom){
                    Rectangle()
                        .background(.white)
                    
                    ScrollViewReader{ proxy in
                        ScrollView(.vertical) {
                            VStack{
                                ForEach(elements){e in
                                    if e == elements.last{
                                        HStack{
                                            Text("\(e.expression) = ")
                                            TextField("Ans", text: $value)
                                                .frame(width: 60)
                                                .underline(pattern: .dash, color: .black)
                                                .foregroundStyle(.black)
                                                .onChange(of: value) { oldValue, newValue in
                                                    if let number = Int(newValue){
                                                        if e.answer == number{
                                                            know += e.sign
                                                            value = ""
                                                            elements.append(Equation())
                                                        }
                                                    }
                                                }
                                                .focused($focusedField, equals: e.id)
                                                .onAppear(){
                                                    proxy.scrollTo("bottom")
                                                    focusedField = e.id
                                                }
                                                .id("bottom")
                                        }
                                    }else{
                                        Text("\(e.expression) = \(e.answer)")
                                    }
                                }
                            }
                            .foregroundStyle(.black)
                            .font(.custom("Chalkduster", size: 30))
                            .padding()
                        }
                        .scrollDisabled(true)
                    }
                }
                .frame(width: 400, height: 500)
                .clipped()
            }
        }
        .onReceive(timer) { _ in
            timeCount += 1
            if timeCount == 1{
                if dataManager.following.count > 0{
                    let chosenCreator = dataManager.following.randomElement()!
                    let prompt = creatorGeneratePrompt(for: chosenCreator, allVideos: dataManager.videos)
                    alertText = "New video from \(chosenCreator)"
                    Task {
                        do{
                            let video = try await generateVideo(prompt: prompt, chosenCreator: chosenCreator, chosenTags: Set<String>())
                            dataManager.videos.append(video)
//                            dataManager.feed.insert(video, at: dataManager.feed.count - 2)
                        }catch{
                            alertText = "We found a video you might like"
                        }
                    }
                }else{
                    alertText = "We found a video you might like"
                }
                showAlert = true
            }else if timeCount == 2{
                alertText = "Come back, we have new videos!"
                showAlert = true
            }else{
                if let studyIndex = dataManager.tasks.firstIndex(where: {$0.name == "study"}), let momIndex = dataManager.chats.firstIndex(where: {$0.user == "danielletan73"}){
                    dataManager.chats[momIndex].messages.append(Message(isMe: false, text: "Good job on your test son!"))
                    dataManager.tasks[studyIndex].done = true
                    dataManager.score += know
                    dismiss()
                }
            }
        }
        .alert("New notification", isPresented: $showAlert) {
            Button("Dismiss"){}
            Button("Open"){
                dataManager.tabSelection = "feed"
                dismiss()
            }
        }message: {
            Text(alertText)
        }
    }
}

#Preview {
    Rectangle()
        .sheet(isPresented: .constant(true)) {
            
            StudyView()
        }
        .preferredColorScheme(.dark)
        .environment(DataManager())
}



