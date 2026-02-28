//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 5/1/26.
//

import SwiftUI

struct StoreView: View {
    let storeItems = [StoreItem(name: "Autoscroll", description: "Let us do the scrolling for you!", cost: 30, image: "rectangle.stack.badge.play")]
    @Environment(DataManager.self) var dataManager
    var body: some View {
        @Bindable var dataManager = dataManager
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]){
                    ForEach(storeItems){item in
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
                            Button{
                                if item.name == "Autoscroll"{
                                    dataManager.autoscroll = true
                                }
                            }label: {
                                HStack{
                                    Image(systemName: "face.smiling")
                                    Text(dataManager.autoscroll ? "Bought!" : String(item.cost))
                                }
                            }
                            .padding()
                            .background(dataManager.score < item.cost || dataManager.autoscroll ? Color.gray:Color.accentColor)
                            .foregroundStyle(.white)
                            .bold()
                            .mask{
                                RoundedRectangle(cornerRadius: 10)
                            }
                            .disabled(dataManager.score < item.cost || dataManager.autoscroll)
                        }
                        .frame(width: 300, height: 300)
                        .background(Color.primary.opacity(0.1))
                        .mask(RoundedRectangle(cornerRadius: 25))
                        
                    }
                }
            }
            .navigationTitle("Store")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    HStack{
                        Image(systemName: "face.smiling")
                        Text("\(dataManager.score)")
                    }
                        .bold()
                        .padding(10)
                }
            }
        }
    }
}

#Preview {
    StoreView()
}
struct StoreItem: Identifiable{
    var id = UUID()
    var name: String
    var description: String
    var cost: Int
    var image: String
}
