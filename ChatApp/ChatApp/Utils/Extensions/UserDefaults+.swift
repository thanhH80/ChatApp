//
//  UserDefaults+.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//

import Foundation

extension UserDefaults {
    
    private enum UserStatus: String {
        case isLoggedIn
    }
    
    var isLoggedIn: Bool {
        get {
            bool(forKey: UserStatus.isLoggedIn.rawValue)
        } set {
            setValue(newValue, forKey: UserStatus.isLoggedIn.rawValue)
        }
    }
    
    private enum UserInfor: String {
        case userEmail
        case profilePictureURL
        case userName
    }
    
    var userName: String {
        get {
            string(forKey: UserInfor.userName.rawValue) ?? ""
        } set {
            setValue(newValue, forKey: UserInfor.userName.rawValue)
        }
    }
    
    var userEmail: String {
        get {
            string(forKey: UserInfor.userEmail.rawValue) ?? ""
        } set {
            setValue(newValue, forKey: UserInfor.userEmail.rawValue)
        }
    }
    
    var profilePictureURL: String {
        get {
            string(forKey: UserInfor.profilePictureURL.rawValue) ?? ""
        } set {
            setValue(newValue, forKey: UserInfor.profilePictureURL.rawValue)
        }
    }
}
