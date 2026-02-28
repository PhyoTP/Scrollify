//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 1/2/26.
//

import SwiftUI

struct BowlingView: View {
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var currentOffset = 0.0
    @State private var endOffset = 0.0
    @State private var startOffset: Double?
    @State private var yOffset = 0.0
    @State private var opacity = 1.0
    @State private var score = 0
    @State private var lastScore = 0
    @Environment(\.dismiss) var dismiss
    @Environment(DataManager.self) var dataManager
    @State private var timeCount = 0
    @State private var alertText = ""
    @State private var showAlert = false
    var body: some View {
        @Bindable var dataManager = dataManager
        GeometryReader{ geometry in
            
            VStack(spacing: 0){
                VStack(spacing: 10){
                    Rectangle()
                        .frame(maxWidth: .infinity,maxHeight: 20)
                    ZStack{
                        Rectangle()
                            .foregroundStyle(Color.accentColor)
                        VStack{
                            Text("Score: \(score)")
                                .font(.custom("HelveticaNeue-bold", size: 30))
                            if lastScore != 0{
                                Text("You knocked down \(lastScore) pins")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20))
                            }
                            if score == 0{
                                Text("Drag the ball up to throw")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20))
                            }
                        }
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .frame(width: geometry.size.width/2)
                    .mask(RoundedRectangle(cornerRadius: 25))
                    ZStack(alignment: .bottom){
                        Rectangle()
                        Text("🎳")
                            .font(.system(size: 50))
                            .zIndex(20)
                    }
                    .frame(width: geometry.size.width/3)
                }
                .offset(y: -geometry.size.width/30)
                ZStack{
                    Rectangle()
                        .scale(2.0)
                        .foregroundStyle(.brown)
                        .frame(width: geometry.size.width/4, height: geometry.size.width/2)
                        .rotation3DEffect(Angle(degrees: 30), axis: (x: 1, y: 0, z: 0))
                    Rectangle()
                        .frame(width: geometry.size.width/2, height: 10)
                        .foregroundStyle(.white)
                        .offset(y: 100)
                }
                if opacity == 1.0{
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 50))
                        .frame(height: 100)
                        .foregroundStyle(Color.accentColor)
                        .offset(x: currentOffset, y: yOffset)
                        .shadow(radius: 10, y: 10)
                        .simultaneousGesture(DragGesture()
                            .onChanged{ value in
                                if value.translation.width + endOffset > 0{
                                    currentOffset = min(value.translation.width + endOffset, geometry.size.width/3)
                                }else{
                                    currentOffset = max(value.translation.width + endOffset, -geometry.size.width/3)
                                }
                                if startOffset == nil{
                                    startOffset = currentOffset
                                }
                                yOffset = max(value.translation.height,-200)
                            }
                            .onEnded { value in
                                
                                endOffset += value.translation.width
                                if value.translation.height < -100{
                                    withAnimation(.linear) {
                                        yOffset = -geometry.size.height/1.6
                                        let overall = currentOffset + endOffset - startOffset!
                                        if overall > 0{
                                            currentOffset = min(overall/10*3, geometry.size.width/10)
                                        }else if overall < 0{
                                            currentOffset = max(overall/10*3, -geometry.size.width/10)
                                        }else{
                                            currentOffset = 0
                                        }
                                        let distance = abs(currentOffset)

                                        let normalized = 1 - (distance / geometry.size.width*10)

                                        lastScore = Int(normalized * 10)

                                        score += lastScore
                                    }
                                    withAnimation(.linear.delay(0.5)){
                                        opacity = 0.0
                                    }
                                }
                                startOffset = nil
                                yOffset = 0.0
                                
                            })
                        .opacity(opacity)
                        .zIndex(10)
                        .onAppear(){
                            currentOffset = geometry.size.width/3
                            endOffset = currentOffset
                            withAnimation {
                                currentOffset = Double.random(in: -geometry.size.width/3...currentOffset)
                                endOffset = currentOffset
                            }
                        }
                }else{
                    ActionButton("Retry"){
                        currentOffset = geometry.size.width/3
                        endOffset = currentOffset
                        withAnimation {
                            currentOffset = Double.random(in: -geometry.size.width/3...currentOffset)
                            endOffset = currentOffset
                        }
                        yOffset = 0.0
                        opacity = 1.0
                    }
                    .font(.system(size: 20))
                    .frame(height: 100)
                }
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
                if let bowlIndex = dataManager.tasks.firstIndex(where: {$0.name == "bowlingmain"}), let friendIndex = dataManager.chats.firstIndex(where: {$0.user == "bobby1479"}){
                    dataManager.tasks[bowlIndex].done = true
                    dataManager.chats[friendIndex].messages.append(Message(isMe: false, text: "That was fun"))
                    dataManager.score += score
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

#Preview(traits: .portrait) {
    @Previewable @State var isPresented: Bool = true
    Rectangle()
        .sheet(isPresented: $isPresented) {
            BowlingView()
        }
        .environment(DataManager())
}
