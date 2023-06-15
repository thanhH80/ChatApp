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
        let email = emailTextField.string
        let password = passwordTextField.string
        alertUser()
        
        showHUD(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, authError in
            guard let strongSelf = self else { return }
            strongSelf.dismisHUD()
            
            if authResult != nil, authError == nil {
                let conversationVC = MainTabbarController.create()
                self?.navigationController?.pushViewController(conversationVC, animated: true)
            } else {
                print(authError?.localizedDescription ?? "")
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
            
            guard let user = gresult?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            guard let userEmail = user.profile?.email,
                  let firstName = user.profile?.givenName,
                  let lastName = user.profile?.familyName else {
                      print("Cannot found user's profile")
                      return
                  }
            
            // Check user
            DatabaseManager.shared.checkExistedUser(userEmail: userEmail) { exist in
                if !exist {
                    DatabaseManager.shared.inserUser(with: UserModel(firstname: firstName,
                                                                     lastname: lastName,
                                                                     emailAddress: userEmail))
                } else {
                    print("edasdasdasdasdasda")
                }
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
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
                                                   parameters: ["fields" : "email, name"],
                                                   tokenString: token,
                                                   version: nil,
                                                   httpMethod: .get)
        fbRequest.start { connection, rqResult, rqError in
            guard let result = rqResult as? [String: Any], rqError == nil else {
                print("REQUEST ERROR: \(String(describing: rqError?.localizedDescription))")
                return
            }
            
            guard let userName = result["name"] as? String,
                let userEmail = result["email"] as? String else {
                 print("Failed to get email from result")
                 return
            }
            
            let nameComponent = userName.components(separatedBy: " ")
            guard nameComponent.count == 2 else {return}
            let firstName = nameComponent[0]
            let lastName = nameComponent[1]
            
            DatabaseManager.shared.checkExistedUser(userEmail: userEmail) { exist in
                if !exist {
                    DatabaseManager.shared.inserUser(with: UserModel(firstname: firstName,
                                                                     lastname: lastName,
                                                                     emailAddress: userEmail))
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

