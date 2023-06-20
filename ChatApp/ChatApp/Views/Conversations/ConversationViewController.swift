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
    
    class func create() -> ConversationViewController {
        let vc = ConversationViewController.instantiate(storyboard: .conversation)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    }
    
    @objc private func didTapSearch() {
        let newConVC = NewConversationViewController.create()
        newConVC.completion = { [weak self] userResult in
            print("\(userResult)")
            self?.createNewConversation(result: userResult)
        }
        let navC = BaseNavigationController(rootViewController: newConVC)
        present(navC, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let userName = result[UserResponse.userName.dto],
              let email = result[UserResponse.email.dto] else {
            print("Cannot get user's name and email")
            return
        }
        
        let messVC = ChatViewController.create(with: email)
        messVC.title = userName
        messVC.isNewConversation = true
        navigationController?.pushViewController(messVC, animated: true)
    }
    
    private func checkUserLoggedIn() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let logginVC = LoginViewController.create()
            navigationController?.pushViewController(logginVC, animated: false)
        }
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let messVC = ChatViewController.create(with: "test@gmail.com")
        messVC.title = "Thagion"
        navigationController?.pushViewController(messVC, animated: true)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)
        cell.textLabel?.text = "Hello Thagion"
        return cell
    }
    
    
}

