//
//  File.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 2/1/26.
//

import Foundation

struct Chat: Equatable{
    var user: String
    var messages: [Message]
}
struct Message: Identifiable, Equatable{
    var id = UUID()
    var isMe: Bool
    var text: String
}
