//
//  ChatViewController.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
//import MessageKit

class ChatViewController: UIViewController { }
    
//    private let sampleSender = Sender(senderId: "1", displayName: "ThagionHS", photoURL: "")
//    private var messages = [MessageModel]()
//
//    class func create() -> ChatViewController {
//        let vc = ChatViewController.instantiate(storyboard: .conversation)
//        return vc
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        getAllMessages()
//    }
//
//    private func getAllMessages() {
//        messages.append(MessageModel(sender: sampleSender,
//                                     messageId: "1",
//                                     sentDate: Date(),
//                                     kind: .text("This is test messages!")))
//
//        messages.append(MessageModel(sender: sampleSender,
//                                     messageId: "2",
//                                     sentDate: Date(),
//                                     kind: .text("This is test messages!, This is test messages!  This is test messages! This is test messages!")))
//    }
//
//    private func setupUI() {
//        navigationController?.navigationBar.prefersLargeTitles = false
//
//        // Mess delegate
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.messagesDataSource = self
//    }
//}
//
//extension ChatViewController: MessagesDataSource {
//    func currentSender() -> SenderType {
//        return sampleSender
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.section]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//
//}
//
//extension ChatViewController: MessagesDisplayDelegate {
//
//}
//
//extension ChatViewController: MessagesLayoutDelegate {
//
//}
