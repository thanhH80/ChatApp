//
//  DataResponse.swift
//  ChatApp
//
//  Created by Thagion Jack on 19/06/2023.
//

import UIKit

enum DataResponse: String {
    case picture
    case url
    case data
    
    var dto: String {
        switch self {
        case .picture:
             return "picture"
        case .url:
            return "url"
        case .data:
            return "data"
        }
    }
}

enum DatabasePath: String {
    case users
    case images
    
    var dto: String {
        switch self {
        case .users:
            return "users"
        case .images:
            return "images"
        }
    }
}
