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
        
    }
}

extension NewConversationViewController: UITableViewDelegate {
    
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newConCell", for: indexPath)
        cell.textLabel?.text = "Hello"
        return cell
    }
    
    
}
