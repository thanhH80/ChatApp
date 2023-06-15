//
//  AppUtils.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import Foundation
import UIKit

class AppUtils: NSObject {
    
    static func setRootController(root viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?  = nil) {
        guard let window = AppDelegate.shared.window else { return }
        UIView.transition(with: window, duration: animated ? 0.3 : 0.0, options: .transitionCrossDissolve, animations: nil) { (_) in
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            completion?()
        }
    }
    
}
