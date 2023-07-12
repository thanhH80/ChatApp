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
    
    private var userResult = [SearchResult]()
    private var users = DatabaseManager.UserCollection()
    private var hasFetched = false
    public var completion: ((SearchResult) -> (Void))?
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .blue6A9CFD
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    class func create() -> NewConversationViewController {
        let vc = NewConversationViewController.instantiate(storyboard: .conversation)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    private func setupUI() {
        newConTblView.registerNib(cellClass: NewConversationTableViewCell.self)
        searchBar.becomeFirstResponder()
        view.addSubview(noResultsLabel)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.becomeFirstResponder()
        userResult.removeAll()
        showHUD(in: view)

        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        }
        else {
            DatabaseManager.shared.getAllUser { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get usres: \(error)")
                }
            }
        }
    }

    func filterUsers(with term: String) {
        // update the UI: eitehr show results or show no results label
        guard  hasFetched else {
            return
        }

        let safeEmail = String.makeSafe(UserDefaults.standard.userEmail)

        dismisHUD()

        let results: [SearchResult] = users.filter({
            guard let email = $0[UserResponse.email.dto], email != safeEmail else {
                return false
            }

            guard let name = $0[UserResponse.userName.dto]?.lowercased() else {
                return false
            }

            return name.contains(term.lowercased())
        }).compactMap({

            guard let email = $0[UserResponse.email.dto],
                let name = $0[UserResponse.userName.dto] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        userResult = results

        updateUI()
    }

    func updateUI() {
        if userResult.isEmpty {
            noResultsLabel.isHidden = false
            newConTblView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            newConTblView.isHidden = false
            newConTblView.reloadData()
        }
    }
}

extension NewConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        // start a conversation
        let foudUser = userResult[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(foudUser)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: NewConversationTableViewCell.self, for: indexPath)
        let model = userResult[indexPath.row]
        cell.config(with: model)
        return cell
    }
    
    
}
