//
//  DisplayAlert.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//


import Foundation
import UIKit

enum CustomAlertTitle {
    case confirm
    case error
    case update
    case other(_ title: String)
    
    var text: String {
        switch self {
        case .confirm: return "Confirm"
        case .error: return "Got error!"
        case .update: return "Update infor"
        case .other(let title): return title
        }
    }
}

// MARK: - Alert Message
enum CustomAlertMessage {
    case nameLengthOver
    case invalidEmailCharacter
    case invalidPassword
    case invalidConfirmPass
    case wrongPassword
    case wrongEmail
    case wrongPhoneNumber
    case notEmpty
    case other(_ message: String)
    
    var text: String {
        switch self {
        case .nameLengthOver:
            return "Name too long!"
        case .invalidEmailCharacter:
            return "Invalid email"
        case .invalidPassword:
            return "Invalid password!"
        case .invalidConfirmPass:
            return "Invalid confirm password!"
        case .wrongEmail:
            return "Wrong email!"
        case .wrongPassword:
            return "Wrong password!"
        case .wrongPhoneNumber:
            return "Wrong phone number!"
        case .notEmpty:
            return "This fields is not empty!"
        case .other(let message):
            return message
        }
    }
}


// MARK: - Alert Button Title

enum CustomAlertButtonTitle {
    
    case cancel
    case ok
    case setting
    case other(_ title: String)
    
    var text: String {
        switch self {
        case .cancel: return "Cancel"
        case .ok: return "OK"
        case .setting: return "Setting"
        case .other(let title): return title
        }
    }
}

struct CustomAlertAction {
    let customAlertButtonTitle: CustomAlertButtonTitle?
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
    
    init(customAlertButtonTitle: CustomAlertButtonTitle?, handler: ((UIAlertAction) -> Void)? = nil) {
        
        self.customAlertButtonTitle = customAlertButtonTitle
        if customAlertButtonTitle?.text == CustomAlertButtonTitle.cancel.text {
            self.style = .cancel
        } else {
            self.style = .default
        }
        
        self.handler = handler
    }
}

// MARK: - Display Alert

protocol DisplayAlert {
    func displayAlert(
        customAlertTitle: CustomAlertTitle?, customAlertMessage: CustomAlertMessage?,
        actions: [UIAlertAction]?, style: UIAlertController.Style,
        completion: (() -> Void)?)
    
    func displayAlert(
        customAlertTitle: CustomAlertTitle?, customAlertMessage: CustomAlertMessage?,
        actions: [CustomAlertAction]?, style: UIAlertController.Style,
        completion: (() -> Void)?)
}

extension DisplayAlert where Self: UIViewController {
    
    func displayAlert(
        customAlertTitle: CustomAlertTitle? = nil,
        customAlertMessage: CustomAlertMessage? = nil,
        actions: [UIAlertAction]? = nil,
        style: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        
        let alertController = UIAlertController(title: customAlertTitle?.text, message: customAlertMessage?.text, preferredStyle: style)
        
        if let actions = actions {
            actions.forEach {
                alertController.addAction($0)
            }
        } else {
            let okAlertAction = UIAlertAction(title: CustomAlertButtonTitle.ok.text, style: .default)
            alertController.addAction(okAlertAction)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: completion)
        }
        
    }
    
    func displayAlert(
        customAlertTitle: CustomAlertTitle? = nil,
        customAlertMessage: CustomAlertMessage? = nil,
        actions: [CustomAlertAction]? = nil,
        style: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        
        let alertController = UIAlertController(title: customAlertTitle?.text, message: customAlertMessage?.text, preferredStyle: style)
        
        if let actions = actions {
            actions.forEach {
                let action = UIAlertAction.init(
                    title: $0.customAlertButtonTitle?.text,
                    style: $0.style,
                    handler: $0.handler)
                alertController.addAction(action)
            }
        } else {
            let okAlertAction = UIAlertAction(title: CustomAlertButtonTitle.ok.text, style: .default)
            alertController.addAction(okAlertAction)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: completion)
        }
        
    }
    
}

extension UIViewController: DisplayAlert { }


