//
//  UserResponse.swift
//  ChatApp
//
//  Created by Thagion Jack on 18/06/2023.
//

import UIKit

enum UserResponse: String {
    case firstName
    case lastName
    case email
    case userName
    
    var dto: String {
        switch self {
        case .firstName:
            return "first_name"
        case .lastName:
            return "last_name"
        case .email:
            return "email"
        case .userName:
            return "user_name"
        }
    }
}
