//
//  NewConversationViewController.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//

import UIKit

class NewConversationViewController: BaseViewController {
    
    @IBOutlet private weak var newConTblView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var userResult = DatabaseManager.UserCollection()
    private var users = DatabaseManager.UserCollection()
    private var hasFetched = false
    
    class func create() -> NewConversationViewController {
        let vc = NewConversationViewController.instantiate(storyboard: .conversation)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func setupUI() {
        
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.replacingOccurrences(of: " ", with: "").isEmpty else {
            userResult.removeAll()
            return
        }
      //  userResult.removeAll()
        //newConTblView.reloadData()
        showHUD(in: view)
        searchUser(with: query)
    }
    
    private func searchUser(with query: String) {
        if hasFetched {
            fillterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUser { [weak self] result in
                self?.dismisHUD()
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.fillterUsers(with: query)
                case .failure(let error):
                    print("Cannot foud user \(error)")
                }
            }
        }
        
    }
    
    private func fillterUsers(with query: String) {
        guard hasFetched else { return }
        dismisHUD()
        let result = users.filter({
            guard let userName = $0["userName"]?.lowercased() else {
                return false
            }
            return userName.contains(query.lowercased())
        })
        userResult = result
        updateUI()
    }
    
    private func updateUI() {
        if userResult.isEmpty {
            newConTblView.isHidden = true
            let noResultLabel = UILabel(frame: .zero)
            noResultLabel.text = "No user found"
            noResultLabel.font = .systemFont(ofSize: 30)
            noResultLabel.textAlignment = .center
        } else {
            newConTblView.reloadData()
        }
        
    }
}

extension NewConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        // start a conversation
    }
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newConCell", for: indexPath)
        if userResult.isEmpty {
            cell.textLabel?.text = "No user found"
        } else {
            cell.textLabel?.text = userResult[indexPath.row]["userName"]
        }
        
        return cell
    }
    
    
}
