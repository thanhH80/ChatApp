//
//  DatabaseManager.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 03/06/2023.
//

import Foundation
import FirebaseDatabase
import SwiftDate
import MessageKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let dbRef = Database.database(url: StringContant.dbURL.rawValue).reference()
    
    public typealias UserCollection = [[String:String]]
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
            UserResponse.firstName.dto: user.firstname,
            UserResponse.lastName.dto: user.lastname
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to DB")
                completion(false)
                return
            }

            // insert user collection
            self.dbRef.child(DatabasePath.users.dto).observeSingleEvent(of: .value) { snapshot in
                if var userCollection = snapshot.value as? UserCollection {
                    let newElement = [
                        UserResponse.email.dto : String.makeSafe(user.emailAddress),
                        UserResponse.userName.dto: user.firstname + " " + user.lastname
                    ]
                    userCollection.append(newElement)
                    
                    self.dbRef.child(DatabasePath.users.dto).setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else {
                    let userCollection: UserCollection = [
                        [
                            UserResponse.email.dto : String.makeSafe(user.emailAddress),
                            UserResponse.userName.dto: user.firstname + " " + user.lastname
                        ]
                    ]
                    self.dbRef.child(DatabasePath.users.dto).setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        })
    }
    
    public func getAllUser(with completion: @escaping (Result<UserCollection, DatabaseError>) -> Void ) {
        dbRef.child(DatabasePath.users.dto).observeSingleEvent(of: .value) { snapshot in
            guard let userCollection = snapshot.value as? UserCollection else {
                completion(.failure(.failedToGetUser))
                return
            }
            completion(.success(userCollection))
        }
    }
}

// MARK: - Sending message

extension DatabaseManager {
    /// Create a new conversation with target user and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: MessageModel, completion: @escaping (Bool) -> Void ) {
        
        let userEmail = UserDefaults.standard.userEmail
        let safeUserEmail = String.makeSafe(userEmail)
        let userRef = dbRef.child(safeUserEmail)
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else { return }
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let sentDate = firstMessage.sentDate.toLocalTime()
            let sentDateString = sentDate.toFormat(dateAndTimeFormat)
            var message = ""
            
            switch firstMessage.kind {
            case .text(let newMessage):
                message = newMessage
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "\(ConversationResponse.conversations.string)_\(firstMessage.messageId)"
            
            let newConversation: [String: Any] = [
                ConversationResponse.id.string: conversationID,
                ConversationResponse.otherUserEmail.string: otherUserEmail,
                ConversationResponse.lastestMessage.string : [
                    ConversationResponse.date.string: sentDateString,
                    ConversationResponse.content.string: message,
                    ConversationResponse.isRead.string: false
                ]
            ]
            
            // if a conversation exists, append a new comversation
            if var conversations = userNode[ConversationResponse.conversations.string] as? [[String: Any]] {
                conversations.append(newConversation)
                
                userNode[ConversationResponse.conversations.string] = conversations
                userRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.finishCreateConversation(with: conversationID, firstMessage: firstMessage, completion: completion)
                }
            } else {
                userNode[ConversationResponse.conversations.string] = [newConversation]
                userRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.finishCreateConversation(with: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    private func finishCreateConversation(with conversationID: String, firstMessage: MessageModel, completion: @escaping (Bool) ->Void) {
        
        var message = firstMessage.kind.text
//        switch firstMessage.kind {
//        case .text(let newMessage):
//            message = newMessage
//        case .attributedText(_):
//            break
//        case .photo(_):
//            break
//        case .video(_):
//            break
//        case .location(_):
//            break
//        case .emoji(_):
//            break
//        case .audio(_):
//            break
//        case .contact(_):
//            break
//        case .linkPreview(_):
//            break
//        case .custom(_):
//            break
//        }
        
        let sentDate = firstMessage.sentDate.toLocalTime()
        let sentDateString = sentDate.toFormat(dateAndTimeFormat)
        
       // MessageResponse.id.string
        
        let newMessages: [String: Any] = [
            MessageResponse.id.string: firstMessage.messageId,
            MessageResponse.type.string: firstMessage.kind.description,
            MessageResponse.content.string: message,
            MessageResponse.date.string: sentDateString,
            MessageResponse.senderEmail.string: UserDefaults.standard.userEmail,
            MessageResponse.isRead.string: false
        ]
        
        let value: [String: Any] = [
            MessageResponse.message.string : [newMessages]
        ]
        
        let conversationNode = dbRef.child("\(conversationID)")
        
        conversationNode.setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                print("Cannot create conversation")
                return
            }
            completion(true)
        }
    }
    
    /// Get all conversation for passed email
    public func getAllConversation(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Get all message from conversation with passed ID
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send a message to conversation
    public func sendMessage(to conversation: String, message: MessageModel, completion: @escaping (Bool) -> Void ) {
        
    }
}
