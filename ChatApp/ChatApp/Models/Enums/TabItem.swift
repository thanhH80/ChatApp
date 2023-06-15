//
//  TabItem.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 03/06/2023.
//

import Foundation
import UIKit

enum TabItem {
    case chat
    case profile
    
    var title: String {
        switch self {
        case .chat:
            return "Chats"
        case .profile:
            return "Profile"
        }
    }
}
