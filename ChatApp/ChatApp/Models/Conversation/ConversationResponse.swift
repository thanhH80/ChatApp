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
    case otherUserEmail
    case lastestMessage
    case date
    case content
    case isRead
    
    var string: String {
        switch self {
        case .id:
            return "id"
        case .conversations:
            return "conversations"
        case .otherUserEmail:
            return "other_user_email"
        case .lastestMessage:
            return "lastest_message"
        case .date:
            return "date"
        case .content:
            return "content"
        case .isRead:
            return "is_read"
        }
    }
}
