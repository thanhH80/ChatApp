//
//  ViewController.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//

import UIKit
import FirebaseAuth

class ConversationViewController: BaseViewController {

    @IBOutlet private weak var conversationTblView: UITableView!
    
    private var conversationsList = [ConversationModel]()
    
    class func create() -> ConversationViewController {
        let vc = ConversationViewController.instantiate(storyboard: .conversation)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserLoggedIn()
        customNavigationTitleView(title: TabItem.chat.title)
    }
    
    private func setupUI() {
        tabBarHidden = false
        navBarHidden = false
        
        // Right nav bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        
        // Table view
        conversationTblView.registerNib(cellClass: ConversationTableViewCell.self)
    }
    
    @objc private func didTapSearch() {
        let newConVC = NewConversationViewController.create()
        newConVC.completion = { [weak self] userResult in
            let currentConversation = self?.conversationsList
            if let targetConversation = currentConversation?.first(where: {
                $0.ohterUserEmail == String.makeSafe(userResult.email)
            }) {
                let vc = ChatViewController.create(with: targetConversation.ohterUserEmail,
                                                   id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: false)
            } else {
                self?.createNewConversation(result: userResult)
            }
        }
        
        let navC = BaseNavigationController(rootViewController: newConVC)
        present(navC, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: SearchResult) {
        let userName = result.name
        let email = String.makeSafe(result.email)
        
        DatabaseManager.shared.conversationExisted(with: email) { [weak self] result in
            switch result {
            case .success(let conversationID):
                let messVC = ChatViewController.create(with: email, id: conversationID)
                messVC.title = userName
                messVC.isNewConversation = true
                self?.navigationController?.pushViewController(messVC, animated: true)
            case .failure(_):
                let messVC = ChatViewController.create(with: email, id: "")
                messVC.title = userName
                messVC.isNewConversation = true
                self?.navigationController?.pushViewController(messVC, animated: true)
            }
        }
    }
    
    private func getConversations() {
        let currentEmail = UserDefaults.standard.userEmail
        let safeCurrEmail = String.makeSafe(currentEmail)
        
        DatabaseManager.shared.getAllConversation(for: safeCurrEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("Conversation is empty")
                    return
                }
                self?.conversationsList = conversations
                DispatchQueue.main.async {
                    self?.conversationTblView.reloadData()
                }
            case .failure(let error):
                print("Got error when get all conversation from VC \(error)")
            }
        }
    }
    
    private func checkUserLoggedIn() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let logginVC = LoginViewController.create()
            navigationController?.pushViewController(logginVC, animated: false)
        }
    }
}

// MARK: - TableView
extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversationsList[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        let messVC = ChatViewController.create(with: model.ohterUserEmail, id: model.id)
        messVC.title = model.name
        navigationController?.pushViewController(messVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.00
    }
    
    // Delete conversation
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conversationID = conversationsList[indexPath.row].id
            print(conversationID)
            DatabaseManager.shared.deleteConversation(with: conversationID) { [weak self] susscess in
                if susscess {
                    DispatchQueue.main.async {
                        self?.conversationsList.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } else {
                    print("Cannot delete")
                }
            }
            
        }
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversationsList[indexPath.row]
        let cell = tableView.dequeueCell(ofType: ConversationTableViewCell.self, for: indexPath)
        cell.configure(with: model)
        return cell
    }
    
    
}

