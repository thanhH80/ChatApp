//
//  DatabaseManager.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 03/06/2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let dbRef = Database.database(url: StringContant.dbURL.rawValue).reference()
}

// MARK: - Account Manager
extension DatabaseManager {
    
    public func checkExistedUser(userEmail: String,
                                 completion: @escaping (Bool) -> Void) {
        dbRef.child(String.makeSafe(userEmail)).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    public func inserUser(with user: UserModel, completion: @escaping (Bool) -> Void) {
        dbRef.child(String.makeSafe(user.emailAddress)).setValue([
            "first_name": user.firstname,
            "last_name": user.lastname
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to DB")
                completion(false)
                return
            }
            completion(true)
        })
    }
}
