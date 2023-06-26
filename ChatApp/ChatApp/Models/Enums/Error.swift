//
//  Error.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit

enum StorageErorr: Error {
    case failedToUpload
    case failedToGetDownloadURL
}

enum DatabaseError: Error {
    case failedToGetUser
    case failedToGetConversations
    case failedToGetMessages
    case failedToGetData
}

