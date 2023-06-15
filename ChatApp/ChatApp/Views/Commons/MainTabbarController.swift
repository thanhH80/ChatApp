//
//  MainTabbarController.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit

class MainTabbarController: UITabBarController {

    class func create() -> MainTabbarController {
        let vc = MainTabbarController.instantiate(storyboard: .mainTabbar)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setSelectedTabBar(byRootViewController: ConversationViewController.self)
        // to prevent lager nav bar
        navigationController?.navigationBar.isHidden = true
    }
}

extension MainTabbarController {
    private func setupViewControllers() {
        let conversationVC = ConversationViewController.create()
        setupChildVC(conversationVC, title: TabItem.chat.title, imageName: "")
        
        let profilevc = ProfileViewController.create()
        setupChildVC(profilevc, title: TabItem.profile.title, imageName: "")
    }
    
    private func setupChildVC(_ childVC: UIViewController, title: String, imageName: String?) {
        let baseNav = BaseNavigationController(rootViewController: childVC)
        baseNav.tabBarItem.title = title
        if let image = imageName {
            baseNav.tabBarItem.image = UIImage(named: image)
        }
        
        addChild(baseNav)
    }
}

extension MainTabbarController {
    private func setSelectedTabBar(byRootViewController type: UIViewController.Type) {
        guard let index = getIndexOfTabBarItem(byRootViewControllerType: type) else { return}
        selectedIndex = index
    }
    
    private func getIndexOfTabBarItem(byRootViewControllerType type: UIViewController.Type) -> Int? {
        guard let viewControllers = viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if let firstVCOfNavigation = (viewController as? UINavigationController)?.viewControllers.first {
                if firstVCOfNavigation.isKind(of: type) {
                    return index
                }
            }
        }
        return nil
    }
}
