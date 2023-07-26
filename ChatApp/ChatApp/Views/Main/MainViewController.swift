//
//  MainViewController.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import UIKit

import RxSwift

class MainViewController: BaseViewController, ViewControllerBase {
    var disposeBag: DisposeBag = DisposeBag()
    private var viewModel: MainViewModel!
    
    
    class func create(navigator: MainNavigation) -> MainViewController {
        let viewModel = MainViewModel(navigator: navigator)
        let vc = MainViewController.instantiate(storyboard: .main)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    
}

extension MainViewController {
    
    func bindViewModel() {
        let viewDidAppearSubject = PublishSubject<Void>()
        
        rx.viewDidAppear.take(1)
            .mapToVoid()
            .bind(to: viewDidAppearSubject)
            .disposed(by: disposeBag)
        
        let input = MainViewModel.Input(viewDidAppearTrigger: viewDidAppearSubject)
        
        let output = viewModel.transform(input)
        output.didLoggedIn.drive().disposed(by: disposeBag)
        
    }
}
