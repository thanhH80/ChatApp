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
}
