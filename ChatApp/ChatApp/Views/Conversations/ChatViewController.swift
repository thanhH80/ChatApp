//
//  ChatViewController.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftDate

class ChatViewController: MessagesViewController {
    
    private var sampleSender: Sender? {
        let email = UserDefaults.standard.userEmail
        return Sender(senderId: email ,
                      displayName: "ThagionHS",
                      photoURL: "")
    }
    private var messages = [MessageModel]()
    private var reciverEmail: String = ""
    private var id: String?
    public var isNewConversation = false

    class func create(with otherUserEmail: String, id: String) -> ChatViewController {
        let vc = ChatViewController.instantiate(storyboard: .conversation)
        vc.reciverEmail = otherUserEmail
        vc.id = id
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getAllMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func getAllMessages() {
        DatabaseManager.shared.getAllMessageForConversation(with: id ?? "") { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("Not found any message")
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
            case .failure(let error):
                print("Got error when get all mess from ChatVC: \(error)")
            }
        }
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false

        // Mess delegate
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messageInputBar.delegate = self
    }
}

// MARK: -
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.removeSpace().isEmpty,
              let sender = sampleSender,
              let messageID = createMessageID() else { return }
    
        print("Sending message: =>>> \(text)")
        
        // Send message
        if isNewConversation {
            // create new in db
            let newMessage = MessageModel(sender: sender,
                                          messageId: messageID,
                                          sentDate: Date(),
                                          kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: reciverEmail, firstMessage: newMessage, reciverName: self.title ?? "User") { susscess in
                if susscess {
                    print("Sendding mess \(susscess)")
                } else {
                    print("Cannot sendding mess")
                }
            }
        } else {
            // append to existing one
        }
    }
    
    /// Create messageID with date, otherUserEmai, senderEmail. randomInt
    private func createMessageID() -> String? {
        let dateString = Date().toLocalTime().toFormat(dateAndTimeFormat)
        let currentUserEmail = UserDefaults.standard.userEmail
        let messID = "\(reciverEmail)_\(String.makeSafe(currentUserEmail))_\(dateString)"
        return messID
    }
}

// MARK: - Messages
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        if let sender = sampleSender {
            return sender
        }
        fatalError("Email nil")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }


}

extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: MessagesLayoutDelegate {}

