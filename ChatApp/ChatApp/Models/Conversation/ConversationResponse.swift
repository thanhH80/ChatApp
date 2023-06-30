//
//  ConversationModel.swift
//  ChatApp
//
//  Created by Thagion Jack on 20/06/2023.
//

import Foundation


enum ConversationResponse {
    case id
    case conversations
    case otherEmail
    case lastestMessage
    case date
    case name
    case content
    case isRead
    
    var string: String {
        switch self {
        case .id:
            return "id"
        case .conversations:
            return "conversations"
        case .otherEmail:
            return "other_email"
        case .lastestMessage:
            return "lastest_message"
        case .date:
            return "date"
        case .name:
            return "name"
        case .content:
            return "content"
        case .isRead:
            return "is_read"
        }
    }
}
