//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseCore

class LoginViewController: BaseViewController {
    
    @IBOutlet private weak var loginWithGoogleButton: GIDSignInButton!
    @IBOutlet private weak var loginWithFBButton: FBLoginButton!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    
    class func create() -> LoginViewController {
        let vc = LoginViewController.instantiate(storyboard: .login)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.enableTogglePassword()
        
        setupFBLoginBtn()
    }
    
    private func setupFBLoginBtn() {
        // remove default constraint
        loginWithFBButton.removeConstraints(loginWithFBButton.constraints)
        if let token = AccessToken.current,
           !token.isExpired {
            
        } else {
            loginWithFBButton.permissions = ["public_profile", "email"]
            loginWithFBButton.delegate = self
        }
    }
    
    private func checkInfor() {
        let userEmail = emailTextField.string
        let password = passwordTextField.string
        
        UserDefaults.standard.userEmail = userEmail
        
        alertUser()
        
        showHUD(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: userEmail, password: password) { [weak self] authResult, authError in
            guard let strongSelf = self else { return }
            strongSelf.dismisHUD()
            
            if authResult != nil, authError == nil {
                let conversationVC = MainTabbarController.create()
                strongSelf.navigationController?.pushViewController(conversationVC, animated: true)
            } else {
                strongSelf.displayAlert(customAlertTitle: .error, customAlertMessage:
                        .other(authError?.localizedDescription ?? ""),
                                        actions: [.init(customAlertButtonTitle: .ok)],
                                        style: .alert,
                                        completion: nil)
            }
        }
    }
    
    private func alertUser() {
        
    }
    
    private func navigateToHome() {
        let vc = MainTabbarController.create()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Actions
    @IBAction private func didTapLogin(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        checkInfor()
    }
    
    @IBAction private func didTapRegister(_ sender: Any) {
        let registerVC = RegisterViewController.create()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func didTapLoginWithGG(_ sender: Any) {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] gresult, error in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                print("Error \(String(describing: error))")
                return
            }
            
            guard let gUser = gresult?.user,
                  let idToken = gUser.idToken?.tokenString else { return }
            
            guard let userEmail = gUser.profile?.email,
                  let profileURL = gUser.profile?.imageURL(withDimension: 200) else {
                print("Cannot found user's profile")
                return
            }
            UserDefaults.standard.userEmail = userEmail
            strongSelf.showHUD(in: strongSelf.view)
            
            // Check user
            DatabaseManager.shared.checkExistedUser(userEmail: userEmail) { exist in
                strongSelf.dismisHUD()
                let firstName = gUser.profile?.givenName
                let lastName = gUser.profile?.familyName
                if !exist {
                    let user = UserModel(firstname: firstName ?? "",
                                         lastname: lastName ?? "",
                                         emailAddress: userEmail)
                    DatabaseManager.shared.inserUser(with: user) { sucess in
                        if sucess {
                            // upload image
                            UserDefaults.standard.userName = "\(firstName ?? "") \(lastName ?? "")"
                            URLSession.shared.dataTask(with: profileURL) { data, _ , _ in
                                guard let data = data else {
                                    return
                                }
                                
                                let fileName = user.profilePicName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.profilePictureURL = downloadURL
                                        print(downloadURL)
                                    case .failure(let e):
                                        print("Got error when upload image \(e)")
                                    }
                                }
                            }.resume()
                            
                        }
                    }
                }
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: gUser.accessToken.tokenString)
            
            // User signed in
            FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
                guard result != nil, error == nil else {
                    if let error = error {
                        print("failed to login with fb \(error.localizedDescription)")
                    }
                    return
                }
                strongSelf.navigateToHome()
            }
        }
    }
}

// MARK: - Facebook Login
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else { return }
        
        let fbCredential = FacebookAuthProvider.credential(withAccessToken: token)
        
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                   parameters: ["fields" :
                                                                    "email, first_name, last_name, picture.type(large)"],
                                                   tokenString: token,
                                                   version: nil,
                                                   httpMethod: .get)
        fbRequest.start { connection, rqResult, rqError in
            guard let result = rqResult as? [String: Any], rqError == nil else {
                print("REQUEST ERROR: \(String(describing: rqError?.localizedDescription))")
                return
            }
            
            guard let firstName = result[UserResponse.firstName.dto] as? String,
                  let userEmail = result[UserResponse.email.dto] as? String,
                  let picture = result[DataResponse.picture.dto] as? [String: Any],
                  let data = picture[DataResponse.data.dto] as? [String: Any],
                  let pictureURL = data[DataResponse.url.dto] as? String,
                  let lastName =  result[UserResponse.lastName.dto] as? String else {
                print("Failed to get infor from result")
                return
            }
            // Cached user's infor
            UserDefaults.standard.userEmail = userEmail
           
            
            DatabaseManager.shared.checkExistedUser(userEmail: userEmail) { exist in
                if !exist {
                    let user = UserModel(firstname: firstName,
                                         lastname: lastName,
                                         emailAddress: userEmail)
                    DatabaseManager.shared.inserUser(with: user) { sucess in
                        if sucess {
                            guard let url = URL(string: pictureURL) else { return }
                            // upload image
                            UserDefaults.standard.userName = "\(firstName) \(lastName)"
                            URLSession.shared.dataTask(with: url) { data, response, error in
                                guard let data = data else {
                                    return
                                }
                                let fileName = user.profilePicName
                                StorageManager.shared.uploadProfilePicture(with: data,
                                                                           fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.profilePictureURL = downloadURL
                                        print(downloadURL)
                                    case .failure(let e):
                                        print("Got error when upload image \(e)")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
        }
        
        FirebaseAuth.Auth.auth().signIn(with: fbCredential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            guard authResult != nil, error == nil else {
                if let error = error {
                    print("failed to login with fb \(error.localizedDescription)")
                }
                return
            }
            
            // Login success
            strongSelf.navigateToHome()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let logimng = LoginManager()
        logimng.logOut()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            return true
        }
        return true
    }
}

