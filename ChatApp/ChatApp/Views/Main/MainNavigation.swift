//
//  MainNavigation.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import Foundation


class MainNavigation: Navigator {
    
    private let navigationController: BaseNavigationController?
    
    init(navigationController: BaseNavigationController) {
        self.navigationController = navigationController
    }
    
    enum Destination {
        case main
        case login
        case conversataion
    }
    
    func navigate(to destination: Destination) {
        switch destination {
        case .main:
            let vc = MainViewController.create(navigator: self)
            navigationController?.pushViewController(vc, animated: true)
        case .conversataion:
            // persent base navigaton later
            let vc = ConversationViewController.create()
            navigationController?.pushViewController(vc, animated: true)
        case .login:
            // persent base navigaton later
            let vc = LoginViewController.create()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
