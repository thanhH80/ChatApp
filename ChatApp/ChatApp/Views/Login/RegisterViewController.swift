//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: BaseViewController {
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var confirmPassTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var lastnameTextField: UITextField!
    
    private var imagePicker = UIImagePickerController()
    
    class func create() -> RegisterViewController {
        let vc = RegisterViewController.instantiate(storyboard: .login)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // nav bar
        navBarHidden = false
        customNavigationTitleView(title: "Register")
        
        imagePicker.delegate = self
        firstNameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        profileImageView.makeCircle(withBorderColor: .blueAEE4FF)
        
        // password
        passwordTextField.enableTogglePassword()
        confirmPassTextField.enableTogglePassword()
        
        // pick image
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(pickImage))
        profileImageView.addGestureRecognizer(gesture)

    }
    
    @IBAction private func didTapRegister(_ sender: Any) {
        checkInfor()
    }
    
    private func checkInfor() {
        let firstName = firstNameTextField.string
        let lastName = lastnameTextField.string
        let email = emailTextField.string
        let password = passwordTextField.string
        let confirmPass = confirmPassTextField.string
        
        if firstName.isEmpty, lastName.isEmpty,email.isEmpty, password.isEmpty, confirmPass.isEmpty {
            displayAlert(customAlertTitle: .error,
                         customAlertMessage: .notEmpty,
                         actions: [.init(customAlertButtonTitle: .ok,
                                         handler: nil)],
                         style: .alert,
                         completion: nil)
        }
        
        showHUD(in: view)
        
        // Firebase Auth
        DatabaseManager.shared.checkExistedUser(userEmail: email) { [weak self] isExisted in
            guard let strongSelf = self else { return }
            
            strongSelf.dismisHUD()
            
            if isExisted {
                print("User existed!")
            } else {
                FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                                    password: password,
                                                    completion: { authResult, authError in
                    if authResult != nil, authError == nil {
                        let user = UserModel(firstname: firstName,
                                             lastname: lastName,
                                             emailAddress: email)
                        DatabaseManager.shared.inserUser(with: user) { sucess in
                            if sucess {
                                guard let image = strongSelf.profileImageView.image,
                                      let data = image.pngData() else {
                                    return
                                }
                                UserDefaults.standard.userName = "\(firstName) \(lastName)"
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
                            }
                        }
                        
                        strongSelf.displayAlert(customAlertTitle: .confirm,
                                            customAlertMessage: .other("Sign up success!"),
                                            actions: [
                                                .init(customAlertButtonTitle: .other("Login"),
                                                handler: { _ in
                                                    let loginVC = LoginViewController.create()
                                                    self?.navigationController?.pushViewController(loginVC, animated: false)})],
                                            style: .alert, completion: nil)
                        
                    } else {
                        strongSelf.displayAlert(customAlertTitle: .other("Cannot create user!"),
                                           customAlertMessage: .other(authError?.localizedDescription ?? ""),
                                           actions: [.init(customAlertButtonTitle: .ok, handler: nil)],
                                  style: .alert,
                                  completion: nil)
                    }
                })
            }
        }
    }
}

// MARK: - Image picker
extension RegisterViewController {
    @objc private func pickImage() {
        displayAlert(customAlertTitle: .other("Profile picture"),
                     customAlertMessage: .other("What would you like to take your profile picture?"),
                     actions: [
                        .init(customAlertButtonTitle: .cancel, handler: nil),
                        .init(customAlertButtonTitle: .other("Camera"),
                              handler: { [weak self] _ in
                                  self?.takeAPicture()
                              }),
                        .init(customAlertButtonTitle: .other("Choose photo"),
                              handler: { [weak self] _ in
                                  self?.chooseAPicture()
                              })
                     ],
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
    
}

extension RegisterViewController: UITextFieldDelegate {
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
        }
        picker.dismiss(animated: false, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
}
