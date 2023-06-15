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
        navBarHidden = false

    }
    
    private func setupUI() {
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
        
        // Firebase Auth
        DatabaseManager.shared.checkExistedUser(userEmail: email) { isExisted in
            if isExisted {
                print("User existed!")
            } else {
                FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                                    password: password,
                                                    completion: { [weak self] authResult, authError in
                    if authResult != nil, authError == nil {
                        DatabaseManager.shared.inserUser(with: UserModel(firstname: firstName, lastname: lastName, emailAddress: email))
                        self?.displayAlert(customAlertTitle: .confirm,
                                            customAlertMessage: .other("Sign up success!"),
                                            actions: [
                                                .init(customAlertButtonTitle: .other("Login"),
                                                handler: { _ in
                                                    let loginVC = LoginViewController.create()
                                                    self?.navigationController?.pushViewController(loginVC, animated: false)})],
                                            style: .alert, completion: nil)
                        
                    } else {
                        self?.displayAlert(customAlertTitle: .other("Cannot create user!"),
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
