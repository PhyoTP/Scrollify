//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 5/1/26.
//

import SwiftUI

struct StoreView: View {
    let storeItems = [StoreItem(name: "Autoscroll", description: "Let us do the scrolling for you!", cost: 30, image: "rectangle.stack.badge.play")]
    @Binding var score: Int
    @AppStorage("autoscroll") var autoscroll = false
    var body: some View {
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
                                autoscroll = true
                            }label: {
                                HStack{
                                    Image(systemName: "face.smiling")
                                    Text(autoscroll ? "Bought!" : String(item.cost))
                                }
                            }
                            .padding()
                            .background(score < item.cost || autoscroll ? Color.gray:Color.accentColor)
                            .foregroundStyle(.white)
                            .bold()
                            .mask{
                                RoundedRectangle(cornerRadius: 10)
                            }
                            .disabled(score < item.cost || autoscroll)
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
                        Text("\(score)")
                    }
                        .bold()
                        .padding(10)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var score = 100
    StoreView(score: $score)
}
struct StoreItem: Identifiable{
    var id = UUID()
    var name: String
    var description: String
    var cost: Int
    var image: String
}
