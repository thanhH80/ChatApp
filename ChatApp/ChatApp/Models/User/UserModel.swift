//
//  UserModel.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 03/06/2023.
//

import Foundation

struct UserModel {
    let firstname: String
    let lastname: String
    let emailAddress: String
    
    var profilePicName: String {
        return "\(String.makeSafe(emailAddress))\(StringContant.avatarSuffix.rawValue)"
    }
}
