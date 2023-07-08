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
import SDWebImage

class ChatViewController: MessagesViewController {
    
    private var sampleSender: Sender? {
        let email = UserDefaults.standard.userEmail
        let senderName = UserDefaults.standard.userName
        return Sender(senderId: email ,
                      displayName: senderName,
                      photoURL: "")
    }
    private var messages = [MessageModel]()
    private var reciverEmail: String = ""
    private var conversationId: String?
    public var isNewConversation = false
    private let imagePicker = UIImagePickerController()
    
    class func create(with otherUserEmail: String, id: String) -> ChatViewController {
        let vc = ChatViewController.instantiate(storyboard: .conversation)
        vc.reciverEmail = otherUserEmail
        vc.conversationId = id
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getAllMessages(shouldscrollToLastItem: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func getAllMessages(shouldscrollToLastItem: Bool) {
        DatabaseManager.shared.getAllMessageForConversation(with: conversationId ?? "") { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("Not found any message")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    
                    if shouldscrollToLastItem {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        imagePicker.delegate = self
        
        setupLeftInputButton()
    }
}

// MARK: -
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.removeSpace().isEmpty,
              let sender = sampleSender,
              let messageID = createMessageID() else { return }
        
        print("Sending message: =>>> \(text)")
        print("Messages: =>>> \(messages)")
        
        let newMessage = MessageModel(sender: sender,
                                      messageId: messageID,
                                      sentDate: Date(),
                                      kind: .text(text))
        messageInputBar.inputTextView.text = nil
        // Send message
        if isNewConversation {
            // create new in db
            DatabaseManager.shared.createNewConversationOnUser(with: reciverEmail, firstMessage: newMessage, reciverName: self.title ?? "User") { [weak self] susscess in
                if susscess {
                    print("Sendding mess \(susscess)")
                    self?.isNewConversation = false
                } else {
                    print("Cannot sendding mess")
                }
            }
        } else {
            // append to existing one
            guard let conversationID = conversationId,
                  let reciverName = self.title else { return }
            
            DatabaseManager.shared.sendMessage(to: conversationID, reciverName: reciverName, otherUserEmail: reciverEmail, newMessage: newMessage) { success in
                if success {
                    print("message sent")
                } else {
                    print("not sent")
                }
            }
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

// MARK: - Attach message
extension ChatViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private func setupLeftInputButton() {
        let button = InputBarButtonItem()
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.onTouchUpInside { [weak self] _ in
            self?.presentActionList()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentActionList() {
        displayAlert(customAlertTitle: .other("Attach Media"),
                     customAlertMessage: .other("Where would you like to attach media?"),
                     actions: [.init(customAlertButtonTitle: .other("Camera"), handler: { [weak self] _ in
            self?.takeAPicture()
        }),
                               .init(customAlertButtonTitle: .other("Photo library"), handler: { [weak self] _ in
                                   self?.chooseAPicture()
                               }),
                               .init(customAlertButtonTitle: .cancel, handler: nil)],
                     style: .actionSheet,
                     completion: nil)
    }
    
    private func takeAPicture() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: false, completion: nil)
    }
    
    private func chooseAPicture() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false, completion: nil)
        guard let conversationID = conversationId,
              let sender = sampleSender,
              let reciverName = self.title,
              let messID = createMessageID() else { return }
            
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData() {
            
            let fileName = "photo_message_" + messID.replacingOccurrences(of: " ", with: "") + ".png"
            
            // upload image
            StorageManager.shared.uploadPhotoMessage(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .failure(let e):
                    print("failed to upload photo message \(e)")
                case .success(let url):
                    guard let imgURL = URL(string: url),
                          let placeholderImage = UIImage(systemName: "plus") else {
                        return
                    }
                    print("Message url: \(url)")
                    
                    let mediaMess = Media(url: imgURL,
                                          image: nil,
                                          placeholderImage: placeholderImage,
                                          size: .zero)
                    
                    let newMessage = MessageModel(sender: sender,
                                                  messageId: messID,
                                                  sentDate: Date(),
                                                  kind: .photo(mediaMess))
                    
                    DatabaseManager.shared.sendMessage(to: conversationID, reciverName: reciverName, otherUserEmail: strongSelf.reciverEmail, newMessage: newMessage) { success in
                        if success {
                            print("Success sent photo image")
                        } else {
                            print("Failed to send message")
                        }
                    }
                }
            }
        }
        

    }
    
}

// MARK: - Messages MessagesDataSource
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

extension ChatViewController: MessagesDisplayDelegate {
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? MessageModel else { return }
        
        switch message.kind {
        case .photo(let photo):
            guard let photoUrl = photo.url else { return }
            imageView.sd_setImage(with: photoUrl)
        default:
            break
        }
    }

}

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let selectedMess = messages[indexPath.section]
        switch selectedMess.kind {
        case .photo(let photo):
            guard let photoUrl = photo.url else { return }
            let playerVC = PlayerViewController.create(with: photoUrl)
            navigationController?.pushViewController(playerVC, animated: false)
            
        default:
            break
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {}

