//
//  Message.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 15/06/2023.
//

import Foundation
import MessageKit

struct MessageModel: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}
