//
//  AchievementsView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 25/2/26.
//

import SwiftUI

struct AchievementsView: View {
    let achievements = [Achievement(name: "Get all endings", description: "Complete all of the storylines!", total: 4, image: "point.3.connected.trianglepath.dotted"), Achievement(name: "Complete all starting tasks", description: "Back to basics", total: 3, image: "checklist.checked"), Achievement(name: "Watch 20 generated videos", description: "vibe scroller", total: 20, image: "apple.intelligence"), Achievement(name: "Watch 50 videos", description: "I don't think you understood the purpose of the app...", total: 50, image: "play.square.stack.fill"), Achievement(name: "Like videos with 10 different tags", description: "many interests", total: 10, image: "tag.fill")]
    @Environment(DataManager.self) var dataManager
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                    ForEach(achievements){item in
                        var value: Int {
                            switch item.name {
                            case "Get all endings":
                                return dataManager.endings.count
                            case "Complete all starting tasks":
                                var count = 0
                                let starting = ["watch","like","follow"]
                                for name in starting{
                                    if let task = dataManager.tasks.first(where: {$0.name == name}), task.done{
                                        count += 1
                                    }
                                }
                                return count
                            case "Watch 20 generated videos":
                                return dataManager.videos.count - premadeVideos.count
                            case "Watch 50 videos":
                                return dataManager.videoCount
                            case "Like videos with 10 different tags":
                                return dataManager.likedTags.count
                            default:
                                return 0
                            }
                        }
                        VStack{
                            Image(systemName: item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding()
                                .background(.background)
                                .mask(RoundedRectangle(cornerRadius: 10))
                            Text(item.name)
                                .font(.title)
                            Text(item.description)
                            
                            HStack{
                                Text("\(value) / \(item.total)")
                            }
                            .padding()
                            .background(value < item.total ? Color.gray:Color.accentColor)
                            .foregroundStyle(.white)
                            .bold()
                            .mask{
                                RoundedRectangle(cornerRadius: 10)
                            }
                        }
                        .frame(width: 450, height: 300)
                        .background(Color.primary.opacity(0.1))
                        .mask(RoundedRectangle(cornerRadius: 25))
                        
                    }
                }
            }
            .navigationTitle("Achievements")
        }
    }
}

#Preview {
    AchievementsView()
        .environment(DataManager())
}
struct Achievement: Identifiable{
    var id = UUID()
    var name: String
    var description: String
    var total: Int
    var image: String
}
