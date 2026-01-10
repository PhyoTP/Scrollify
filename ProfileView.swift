//
//  ProfileView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 4/12/25.
//

import SwiftUI

struct ProfileView: View {
    var videos: [Video]
    var name: String
    @Binding var following: Set<String>
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    var body: some View {
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
                if following.contains(name){
                    Button("Following"){
                        showAlert = true
                    }
                    .font(.title)
                    .padding()
                    .glassEffect()
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .padding(5)
                    .alert("Unfollow?", isPresented: $showAlert) {
                        Button("Unfollow", role: .destructive){
                            following.remove(name)
                        }
                    }
                }else{
                    Button("Follow"){
                        withAnimation {
                            _ = following.insert(name)
                        }
                    }
                    .font(.title)
                    .padding()
                    .glassEffect(.regular.tint(.accentColor))
                    .foregroundStyle(.white)
                    .padding(5)
                    
                }
                Divider()
                ScrollView(.vertical){
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]){
                        ForEach(videos.filter{$0.creator == name}){video in
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
#Preview {
    @Previewable @State var following: Set<String> = []
    ProfileView(videos: premadeVideos, name: "cutecats191", following: $following)
}
