//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var tableData = ["Log out"]
    
    class func create() -> ProfileViewController {
        let vc = ProfileViewController.instantiate(storyboard: .profile)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
        tabBarHidden = false
        navBarHidden = false
        customNavigationTitleView(title: TabItem.profile.title)
    }

}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        displayAlert(customAlertTitle: .other(""),
                     customAlertMessage: .other(""),
                     actions: [.init(title: "Log out",
                                     style: .destructive,
                                     handler: { [weak self] _ in
                                    do {
                                        try FirebaseAuth.Auth.auth().signOut()
                                        // FB sign out
                                        FBSDKLoginKit.LoginManager().logOut()
                                        //Google sign out
                                        GIDSignIn.sharedInstance.signOut()
                                        
                                        let loginVC = LoginViewController.create()
                                        self?.navigationController?.pushViewController(loginVC, animated: false)
                                    } catch {
                                        print("Cannot log out")
                                    }
                                }),
                               .init(title: "Cancle", style: .cancel, handler: nil)
                              ],
                     style: .actionSheet,
                     completion: nil)
        
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        profileCell.textLabel?.text = tableData[indexPath.row]
        profileCell.textLabel?.textAlignment = .center
        profileCell.textLabel?.textColor = .red
        return profileCell
    }
}

