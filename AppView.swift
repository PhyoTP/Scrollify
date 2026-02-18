//
//  AppView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 7/2/26.
//

import SwiftUI

struct AppView: View{
    @State private var showSheet = true
    @State private var query = ""
    @State private var newMessageAlert = false
    @State private var storeAlert = false
    @Environment(DataManager.self) var dataManager
    @State private var autoscrollAlert = false
    @State private var taskAlert = false
    @State private var bowlingSheet = false
    @State private var screentimeAlert = false
    @State private var studySheet = false
    var body: some View{
        @Bindable var dataManager = dataManager
        TabView(selection: $dataManager.tabSelection){
            Tab(value: "feed"){
                FeedView()
            } label: {
                Label("Feed", systemImage: "square.stack")
            }
            Tab(value: "chats") {
                ChatsView()
            } label: {
                Label("Chats", systemImage: "bubble.left.and.bubble.right")
            }
            .badge(dataManager.newMessages.count)
            if dataManager.store{
                Tab(value: "store"){
                    StoreView()
                }label: {
                    Label("Store", systemImage: "storefront")
                }
            }
            if dataManager.screentime{
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
                                let filteredCreators = Set(dataManager.videos.compactMap(\.creator)).sorted().filter{$0.lowercased().contains(query.lowercased())}
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                                    ForEach(filteredCreators, id: \.self){creator in
                                        NavigationLink{
                                            ProfileView(name: creator)
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
                                let filteredVideos = dataManager.videos.filter{$0.caption.lowercased().contains(query.lowercased())||$0.text.lowercased().contains(query.lowercased())}
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]){
                                    ForEach(filteredVideos){video in
                                        NavigationLink{
                                            PlayingVideoView(video: video)
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
            Tab(value: "debug"){ // MUST DELETE
                Toggle("has store", isOn: $dataManager.store)
                Toggle("has autoscroll", isOn: $dataManager.autoscroll)
                Toggle("has screen time", isOn: $dataManager.screentime)
            }label: {
                Label("Debug", systemImage: "arrow.2.circlepath.circle")
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
        .onChange(of: dataManager.chats) { oldValue, newValue in
            for i in newValue.indices{
                if oldValue[i].messages.count != newValue[i].messages.count{
                    if newValue[i].messages[oldValue[i].messages.count...].contains(where: {$0.isMe == true}){
                        dataManager.newMessages.removeAll(where: {$0.0 == newValue[i].user})
                    }else{
                        dataManager.newMessages.append(contentsOf: newValue[i].messages[oldValue[i].messages.count...].map{(newValue[i].user, $0)})
                    }
                    if dataManager.tabSelection != "chats"{
                        newMessageAlert = true
                    }
                }
            }
            
        }
        .alert("New message", isPresented: $newMessageAlert) {
            Button("Go to chats"){
                dataManager.tabSelection = "chats"
            }
        } message: {
            if let lastMessage = dataManager.newMessages.last{
                Text(lastMessage.0 + ": " + lastMessage.1.text)
            }
        }
        .onChange(of: dataManager.store) {
            if dataManager.store{
                storeAlert = true
            }
        }
        .alert("New feature!", isPresented: $storeAlert) {
            Button("Go to store"){
                dataManager.tabSelection = "store"
            }
        } message: {
            Text("Store has been added! Spend your dopamine points on cool new items!")
        }
        .onChange(of: dataManager.autoscroll) {
            print("auto changed")
            if dataManager.autoscroll{
                print("auto true")
                autoscrollAlert = true
            }
        }
        .alert("Autoscroll unlocked!", isPresented: $autoscrollAlert) {
            Button("Go to feed"){
                dataManager.tabSelection = "feed"
            }
        } message: {
            Text("You have unlocked autoscrolling, try it out now!")
        }
        .onChange(of: dataManager.tasks.count){
            DispatchQueue.main.async {
                taskAlert = true
            }
        }
        .alert("New task", isPresented: $taskAlert){
            if let lastTask = dataManager.tasks.last{
                if lastTask.name == "bowlingmain"{
                    Button("Go bowling"){
                        bowlingSheet = true
                    }
                }else if lastTask.name == "study"{
                    Button("Later"){}
                    Button("Go study"){
                        studySheet = true
                    }
                }
            }
        } message: {
            if let lastTask = dataManager.tasks.last{
                Text(lastTask.title)
            }
        }
        .sheet(isPresented: $bowlingSheet) {
            BowlingView()
                .preferredColorScheme(.light)
                .environment(dataManager)
        }
        .sheet(isPresented: $studySheet) {
            StudyView()
                .environment(dataManager)
        }
        .onChange(of: dataManager.screentime) {
            if dataManager.screentime{
                screentimeAlert = true
            }
        }
        .alert("New feature!", isPresented: $screentimeAlert) {
            Button("Go to screen time"){
                dataManager.tabSelection = "screentime"
            }
        } message: {
            Text("Screen Time has been added, set an app limit and downtime")
        }
    }
}
