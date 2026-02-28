//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 22/2/26.
//

import SwiftUI

struct TasksView: View {
    @Environment(DataManager.self) var dataManager
    @State private var lastScore = 0
    @State private var show = true
    var body: some View {
        @Bindable var dataManager = dataManager
        VStack{
            let taskValues = [
                "watch": dataManager.videoCount,
                "like": dataManager.likedVideos.count,
                "follow": dataManager.following.count
            ]
            HStack{
                Button{
                    withAnimation {
                        show.toggle()
                    }
                }label: {
                    Image(systemName: show ? "chevron.down.circle" : "chevron.right.circle")
                        .font(.title3)
                }
                .contentTransition(.symbolEffect(.replace))
                Text("Tasks")
                    .font(.title3.bold())
                HStack{
                    Text("\(dataManager.score)")
                        .bold()
                    Image(systemName: "face.smiling")
                    if lastScore > 0{
                        Text("\(lastScore>0 ? "+" : "-")\(lastScore)")
                            .foregroundStyle(lastScore > 0 ? .green : lastScore < 0 ? .red : .clear)
                            .onAppear(){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        lastScore = 0
                                    }
                                }
                            }
                    }
                }
                
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            if show{
                Divider()
                ForEach($dataManager.tasks, id: \.name) { $task in
                    TaskView(task: $task, value: taskValues[task.name] ?? (task.done ? 1 : 0))
                }
            }
        }
        .frame(width: 200)
        .padding()
        .glassEffect(in: .rect(cornerRadius: 25))
        .onChange(of: dataManager.score, { oldValue, newValue in
            withAnimation {
                lastScore += newValue - oldValue
            }
        })
    }
}
struct TaskView: View{
    @Binding var task: ATask
    var value: Int
    @State private var animatedValue = 0.0
    @Environment(DataManager.self) var dataManager
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
