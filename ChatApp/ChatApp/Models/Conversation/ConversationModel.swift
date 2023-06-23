//
//  ConversationModel.swift
//  ChatApp
//
//  Created by Thagion Jack on 21/06/2023.
//

import Foundation

struct ConversationModel {
    let id: String
    let name: String
    let ohterUserEmail: String
    let lastestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
