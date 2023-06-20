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
    private var profilePictureImageView = UIImageView()
    private var tableData = ["Log out"]
    
    class func create() -> ProfileViewController {
        let vc = ProfileViewController.instantiate(storyboard: .profile)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadProfilePicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
        tabBarHidden = false
        navBarHidden = false
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        customNavigationTitleView(title: TabItem.profile.title)
    }
    
    private func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data, _ , error in
            guard let data = data, error == nil else {
                print("Cannot get image data \(String(describing: error?.localizedDescription)) ")
                return
            }
            
            DispatchQueue.main.async {
                let downloadedImage = UIImage(data: data)
                imageView.image = downloadedImage
            }
        }.resume()
    }
    
    private func downloadProfilePicture() {
        let email = UserDefaults.standard.userEmail
        let fileName = String.makeSafe(email) + StringContant.avatarSuffix.rawValue
        let path = "images/" + fileName
        
        StorageManager.shared.fetchDownloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: self?.profilePictureImageView ?? UIImageView(), url: url)
            case .failure(let error):
                print("Got error when fetch download url: \(error)")
            }
        }
    }
    
    private func createTblHeaderView() -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 240))
        headerView.backgroundColor = .pinkFFBFB3
        
        //profile picture
        profilePictureImageView = UIImageView(frame: CGRect(x: (tableView.width - 120) / 2, y: 60, width: 120, height: 120))
        profilePictureImageView.backgroundColor = .white
        profilePictureImageView.makeCircle(withBorderColor: .white)
        profilePictureImageView.contentMode = .scaleAspectFill
        downloadProfilePicture()
        
        headerView.addSubview(profilePictureImageView)
        return headerView
    }
}

// MARK: - UITableViewDelegate
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createTblHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 240.0
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

