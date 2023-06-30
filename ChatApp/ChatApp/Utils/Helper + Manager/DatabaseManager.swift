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
    public typealias DatabaseEntryType = [String: Any]
    
    private func getDateString(from message: MessageModel) -> String {
        let sentDate = message.sentDate.toLocalTime()
        let a = sentDate.toFormat(dateAndTimeFormat)
        return a
    }
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
    
    public func getDataFromPath(path: String, completion: @escaping (Result<Any, DatabaseError>) -> Void) {
        dbRef.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(.failedToGetData))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Sending message

extension DatabaseManager {
    private func createConversationEntry(with conversationID: String,
                                         email: String,
                                         name: String,
                                         dateString: String,
                                         message: String,
                                         isReading: Bool) -> DatabaseEntryType {
        let conversationEntry: DatabaseEntryType = [
            ConversationResponse.id.string: conversationID,
            ConversationResponse.otherEmail.string: email,
            ConversationResponse.name.string: name,
            ConversationResponse.lastestMessage.string : [
                ConversationResponse.date.string: dateString,
                ConversationResponse.content.string: message,
                ConversationResponse.isRead.string: false
            ]
        ]
        return conversationEntry
    }
    /// Create a new conversation with target user and first message sent
    public func createNewConversationOnUser(with reciverEmail: String,
                                            firstMessage: MessageModel,
                                            reciverName: String,
                                            completion: @escaping (Bool) -> Void ) {
        
        let userEmail = UserDefaults.standard.userEmail
        let userSenderName = UserDefaults.standard.userName
        let safeUserEmail = String.makeSafe(userEmail)
        let userRef = dbRef.child("\(safeUserEmail)")
        
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard var userCollection = snapshot.value as? DatabaseEntryType else {
                completion(false)
                
                print("User not found")
                return
            }
            let message = firstMessage.kind.text
            let conversationID = "\(ConversationResponse.conversations.string)_\(firstMessage.messageId)"
            let dateString = strongSelf.getDateString(from: firstMessage)
            let newConversation = strongSelf.createConversationEntry(with: conversationID,
                                                                     email: reciverEmail,
                                                                     name: reciverName,
                                                                     dateString: dateString,
                                                                     message: message,
                                                                     isReading: false)
            
            let reciverConversation = strongSelf.createConversationEntry(with: conversationID,
                                                                         email: safeUserEmail,
                                                                         name: userSenderName,
                                                                         dateString: dateString,
                                                                         message: message,
                                                                         isReading: false)
            
            //Update revicer conversation
            strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                .observeSingleEvent(of: .value) { snapshot in
                    if var reciverConversations = snapshot.value as? [DatabaseEntryType] {
                        reciverConversations.append(reciverConversation)
                        strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                            .setValue(reciverConversations)
                    } else {
                        strongSelf.dbRef.child("\(reciverEmail)/\(ConversationResponse.conversations.string)")
                            .setValue([reciverConversation])
                    }
                    
                }
            
            
            // if a conversation exists, append 
            if var conversationCollection = userCollection[ConversationResponse.conversations.string] as? [DatabaseEntryType] {
                conversationCollection.append(newConversation)
                
                userCollection[ConversationResponse.conversations.string] = conversationCollection
                userRef.setValue(userCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.createNewConversation(with: conversationID,
                                                     senderName: reciverName,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            } else {
                userCollection[ConversationResponse.conversations.string] = [newConversation]
                userRef.setValue(userCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    strongSelf.createNewConversation(with: conversationID,
                                                     senderName: reciverName,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            }
        }
    }
    
    private func createNewConversation(with conversationID: String,
                                       senderName: String,
                                       firstMessage: MessageModel,
                                       completion: @escaping (Bool) ->Void) {
        
        let message = firstMessage.kind.text
        let sentDate = firstMessage.sentDate.toLocalTime()
        let sentDateString = sentDate.toFormat(dateAndTimeFormat)
        
        
        let newMessages: DatabaseEntryType = [
            MessageResponse.id.string: firstMessage.messageId,
            MessageResponse.type.string: firstMessage.kind.description,
            MessageResponse.content.string: message,
            MessageResponse.date.string: sentDateString,
            MessageResponse.senderEmail.string: UserDefaults.standard.userEmail,
            MessageResponse.name.string: senderName,
            MessageResponse.isRead.string: false
        ]
        
        let value: DatabaseEntryType = [
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
            guard let conversationValue = snapshot.value as? [DatabaseEntryType] else {
                completion(.failure(.failedToGetConversations))
                return
            }
            let conversations: [ConversationModel] = conversationValue.compactMap { dictionary in
                guard let conversationID = dictionary[ConversationResponse.id.string] as? String,
                      let name = dictionary[ConversationResponse.name.string] as? String,
                      let reciverEmail = dictionary[ConversationResponse.otherEmail.string] as? String,
                      let lastestMessage = dictionary[ConversationResponse.lastestMessage.string] as? DatabaseEntryType,
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
    public func getAllMessageForConversation(with conversationID: String, completion: @escaping (Result<[MessageModel], DatabaseError>) -> Void) {
        dbRef.child("\(conversationID)/\(MessageResponse.message.string)").observe(.value) { snapshot in
            guard let messageVale = snapshot.value as? [DatabaseEntryType] else {
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
    public func sendMessage(to conversationID: String,
                            reciverName: String,
                            otherUserEmail: String,
                            newMessage: MessageModel,
                            completion: @escaping (Bool) -> Void) {
        let currentEmail = String.makeSafe(UserDefaults.standard.userEmail)
        dbRef.child("\(conversationID)/\(MessageResponse.message.string)")
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard var currentMessCollection = snapshot.value as? [DatabaseEntryType],
                      let strongSelf = self else {
                    completion(false)
                    return
                }
                
                let message = newMessage.kind.text
                //let currentUserEmail = String.makeSafe(UserDefaults.standard.userEmail)
                
                let messageEntry: DatabaseEntryType = [
                    MessageResponse.id.string: newMessage.messageId,
                    MessageResponse.type.string: newMessage.kind.description,
                    MessageResponse.content.string: message,
                    MessageResponse.date.string: strongSelf.getDateString(from: newMessage),
                    MessageResponse.senderEmail.string: UserDefaults.standard.userEmail,
                    MessageResponse.name.string: reciverName,
                    MessageResponse.isRead.string: false
                ]
                currentMessCollection.append(messageEntry)
                
                strongSelf.dbRef.child("\(conversationID)/\(MessageResponse.message.string)")
                    .setValue(currentMessCollection, withCompletionBlock: { err, _ in
                        guard err == nil else {
                            completion(false)
                            return
                        }
                        strongSelf.updateLastestMessage(conversaionID: conversationID,
                                                        email: currentEmail,
                                                        message: newMessage,
                                                        completion: completion)
                        
                        strongSelf.updateLastestMessage(conversaionID: conversationID,
                                                        email: otherUserEmail,
                                                        message: newMessage,
                                                        completion: completion)
                    })
            }
    }
    
    private func updateLastestMessage(conversaionID: String,
                                      email: String,
                                      message: MessageModel,
                                      completion: @escaping (Bool) -> Void) {
        dbRef.child("\(email)/\(ConversationResponse.conversations.string)")
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard var currentConversations = snapshot.value as? [DatabaseEntryType],
                      let strongSelf = self  else {
                    completion(false)
                    return
                }
                let updatedMess = message.kind.text
                let updatedValue: DatabaseEntryType = [
                    ConversationResponse.content.string: updatedMess,
                    ConversationResponse.date.string: strongSelf.getDateString(from: message),
                    ConversationResponse.isRead.string: false
                ]
                for (i, conversation) in currentConversations.enumerated() {
                    if let convoID = conversation[ConversationResponse.id.string] as? String,
                       convoID == conversaionID {
                        currentConversations[i][ConversationResponse.lastestMessage.string] = updatedValue
                        break
                    }
                }
                strongSelf.dbRef.child("\(email)/\(ConversationResponse.conversations.string)")
                    .setValue(currentConversations) { err, _ in
                        if err == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
            }
    }
}
