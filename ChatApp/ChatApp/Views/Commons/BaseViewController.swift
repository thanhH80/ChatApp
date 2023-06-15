//
//  BaseViewController.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//

import UIKit
import JGProgressHUD

class BaseViewController: UIViewController {
    
    var tabBarHidden: Bool = true
    var navBarHidden: Bool = true
    
    private let spiner = JGProgressHUD(style: .dark)
    
    deinit {
        print("▶︎ [Screen - \(className)] deinit !")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBackBarButtonEmptyTitle()
        navigationController?.setNavigationBarHidden(navBarHidden, animated: false)
        tabBarController?.tabBar.isHidden = tabBarHidden
    }
    
    func showHUD(in view: UIView) {
        spiner.show(in: view)
    }
    
    func dismisHUD() {
        DispatchQueue.main.async {
            self.spiner.dismiss()
        }
    }
    
}


extension BaseViewController: CustomNavigation {}
