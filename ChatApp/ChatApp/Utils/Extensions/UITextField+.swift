//
//  UITextField+.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 31/05/2023.
//

import Foundation
import UIKit

extension UITextField {
    
    func setEyeImage(_ button: UIButton) {
        let showPasswordImage = UIImage(systemName: "eye.slash.fill")?.withTintColor(.blue6A9CFD, renderingMode: .alwaysOriginal)
        let hidePasswordImage = UIImage(systemName: "eye.fill")?.withTintColor(.blue6A9CFD, renderingMode: .alwaysOriginal)
        self.isSecureTextEntry ? button.setImage(showPasswordImage, for: .normal) : button.setImage(hidePasswordImage, for: .normal)
    }
    
    func enableTogglePassword() {
        let button = UIButton(type: .custom)
        setEyeImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @objc private func togglePasswordView(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        if let textRange = textRange(from: self.beginningOfDocument, to: self.endOfDocument) {
            self.replace(textRange, withText: self.text ?? "")
        }
            
        setEyeImage(sender)
    }
}

extension UITextField {
    var string: String {
        return (self.text ?? "")
    }
}
