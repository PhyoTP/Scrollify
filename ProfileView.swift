//
//  ProfileView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 4/12/25.
//

import SwiftUI

struct ProfileView: View {
    var name: String
    @Environment(DataManager.self) var dataManager
    @State private var showAlert = false
    var body: some View {
        @Bindable var dataManager = dataManager
        NavigationStack{
            VStack{
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .foregroundStyle(Color.accentColor)
                Text(name)
                    .font(.largeTitle)
                    .bold()
                if dataManager.following.contains(name){
                    Button{
                        showAlert = true
                    }label:{
                        Text("Following")
                            .font(.title)
                            .padding()
                            .glassEffect()
                            .foregroundStyle(.white)
                            .padding(5)
                    }
                    .alert("Unfollow?", isPresented: $showAlert) {
                        Button("Unfollow", role: .destructive){
                            dataManager.following.remove(name)
                        }
                    }
                }else{
                    Button{
                        withAnimation {
                            _ = dataManager.following.insert(name)
                        }
                    }label:{
                        Text("Follow")
                            .font(.title)
                            .padding()
                            .glassEffect(.regular.tint(.accentColor))
                            .foregroundStyle(.white)
                            .padding(5)
                    }
                }
                Divider()
                ScrollView(.vertical){
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]){
                        ForEach(dataManager.videos.filter{$0.creator == name}){video in
                            VideoView(video: video)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(9.0/16.0, contentMode: .fit)
                                .background(Color.accentColor)
                                .mask{
                                    RoundedRectangle(cornerRadius: 50)
                                }
                                .padding()
                        }
                    }
                }
            }
        }
    }
}
//#Preview {
//    ProfileView(videos: premadeVideos, name: "cutecats191")
//}
