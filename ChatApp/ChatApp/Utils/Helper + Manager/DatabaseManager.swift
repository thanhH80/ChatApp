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
    public func createNewConversation(with reciverEmail: String,
                                      firstMessage: MessageModel,
                                      reciverName: String,
                                      completion: @escaping (Bool) -> Void ) {
        
        let userEmail = UserDefaults.standard.userEmail
        let userSenderName = UserDefaults.standard.userName
        let safeUserEmail = String.makeSafe(userEmail)
        let userRef = dbRef.child("\(safeUserEmail)")
        
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let sentDate = firstMessage.sentDate.toLocalTime()
            let sentDateString = sentDate.toFormat(dateAndTimeFormat)
            let message = firstMessage.kind.text
            let conversationID = "\(ConversationResponse.conversations.string)_\(firstMessage.messageId)"
            
            let newConversation: [String: Any] = [
                ConversationResponse.id.string: conversationID,
                ConversationResponse.otherEmail.string: reciverEmail,
                ConversationResponse.name.string: reciverName,
                ConversationResponse.lastestMessage.string : [
                    ConversationResponse.date.string: sentDateString,
                    ConversationResponse.content.string: message,
                    ConversationResponse.isRead.string: false
                ]
            ]
            
            let reciverConversation: [String: Any] = [
                ConversationResponse.id.string: conversationID,
                ConversationResponse.otherEmail.string: safeUserEmail,
                ConversationResponse.name.string: userSenderName,
                ConversationResponse.lastestMessage.string : [
                    ConversationResponse.date.string: sentDateString,
                    ConversationResponse.content.string: message,
                    ConversationResponse.isRead.string: false
                ]
            ]
            
            //UPdate revicer conversation
            strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                .observeSingleEvent(of: .value) { snapshot in
                    if var reciverConversations = snapshot.value as? [[String: Any]] {
                        reciverConversations.append(reciverConversation)
                        strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                            .setValue(reciverConversations)
                    } else {
                        strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                            .setValue([reciverConversation])
                    }
                    
                }
            
            
            // if a conversation exists, append a new comversation
            if var conversations = userNode[ConversationResponse.conversations.string] as? [[String: Any]] {
                conversations.append(newConversation)
                
                userNode[ConversationResponse.conversations.string] = conversations
                userRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.finishCreateConversation(with: conversationID, senderName: reciverName, firstMessage: firstMessage, completion: completion)
                }
            } else {
                userNode[ConversationResponse.conversations.string] = [newConversation]
                userRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.finishCreateConversation(with: conversationID, senderName: reciverName, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    private func finishCreateConversation(with conversationID: String, senderName: String, firstMessage: MessageModel, completion: @escaping (Bool) ->Void) {
        
        let message = firstMessage.kind.text
        let sentDate = firstMessage.sentDate.toLocalTime()
        let sentDateString = sentDate.toFormat(dateAndTimeFormat)
        
       // MessageResponse.id.string
        
        let newMessages: [String: Any] = [
            MessageResponse.id.string: firstMessage.messageId,
            MessageResponse.type.string: firstMessage.kind.description,
            MessageResponse.content.string: message,
            MessageResponse.date.string: sentDateString,
            MessageResponse.senderEmail.string: UserDefaults.standard.userEmail,
            MessageResponse.name.string: senderName,
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
    public func getAllConversation(for email: String, completion: @escaping (Result<[ConversationModel], DatabaseError>) -> Void) {
        dbRef.child("\(email)/\(ConversationResponse.conversations.string)").observe(.value) { snapshot in
            guard let conversationValue = snapshot.value as? [[String: Any]] else {
                completion(.failure(.failedToGetConversations))
                return
            }
            let conversations: [ConversationModel] = conversationValue.compactMap { dictionary in
                guard let conversationID = dictionary[ConversationResponse.id.string] as? String,
                      let name = dictionary[ConversationResponse.name.string] as? String,
                      let reciverEmail = dictionary[ConversationResponse.otherEmail.string] as? String,
                      let lastestMessage = dictionary[ConversationResponse.lastestMessage.string] as? [String: Any],
                      let sentDate = lastestMessage[MessageResponse.date.string] as? String,
                      let isReadMess = lastestMessage[MessageResponse.isRead.string] as? Bool,
                      let content = lastestMessage[MessageResponse.content.string] as? String else {
                    return nil
                }
                
                let lastestMessObject = LatestMessage(date: sentDate, text: content, isRead: isReadMess)
                
                return ConversationModel(id: conversationID,
                                         name: name,
                                         ohterUserEmail: reciverEmail,
                                         lastestMessage: lastestMessObject)
            }
            completion(.success(conversations))
        }
    }
    
    /// Get all message from conversation with passed ID
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<[MessageModel], DatabaseError>) -> Void) {
        dbRef.child("\(id)/message").observe(.value) { snapshot in
            guard let messageVale = snapshot.value as? [[String: Any]] else {
                completion(.failure(.failedToGetMessages))
                return
            }
            let messages: [MessageModel] = messageVale.compactMap { dictionary in
                guard let messageID = dictionary[MessageResponse.id.string] as? String,
                      let reciverName = dictionary[MessageResponse.name.string] as? String,
                      let senderEmail = dictionary[MessageResponse.senderEmail.string] as? String,
                      let dateString = dictionary[MessageResponse.date.string] as? String,
                      let sentDate = dateString.toDate(withFormat: dateAndTimeFormat),
//                      let isReadMess = dictionary[MessageResponse.isRead.string] as? Bool,
//                      let messTpye = dictionary[MessageResponse.type.string] as? String,
                      let content = dictionary[MessageResponse.content.string] as? String else {
                    return nil
                }
                let sender = Sender(senderId: senderEmail, displayName: reciverName, photoURL: "")
                return MessageModel(sender: sender, messageId: messageID, sentDate: sentDate, kind: .text(content))
            }
            completion(.success(messages))
        }
    }
    /// Send a message to conversation
    public func sendMessage(to conversation: String, message: MessageModel, completion: @escaping (Bool) -> Void ) {
        
    }
}
