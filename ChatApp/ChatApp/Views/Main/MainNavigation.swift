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
            print("To conversation")
        case .login:
            print("To Login")
        }
    }
    
    
}
