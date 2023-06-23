//
//  MessageResponse.swift
//  ChatApp
//
//  Created by Thagion Jack on 21/06/2023.
//

import Foundation

enum MessageResponse {
    case message
    case id
    case type
    case content
    case date
    case senderEmail
    case name
    case isRead
    
    var string: String {
        switch self {
        case .message:
            return "message"
        case .id:
            return "id"
        case .type:
            return "type"
        case .content:
            return "content"
        case .date:
            return "date"
        case .senderEmail:
            return "sender_emal"
        case .name:
            return "name"
        case .isRead:
            return "is_read"
        }
    }
}
