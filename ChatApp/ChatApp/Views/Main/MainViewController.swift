//
//  MainViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import UIKit

class MainViewController: BaseViewController {
    
    private var viewModel: MainViewModel!
    
    class func create(navigator: MainNavigation) -> MainViewController {
        let viewModel = MainViewModel(navigator: navigator)
        let vc = MainViewController.instantiate(storyboard: .main)
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

}
