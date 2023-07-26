//
//  MainViewModel.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel: ViewModel {
    var disposeBag: DisposeBag = DisposeBag()
    private let navigator: MainNavigation
    
    init(navigator: MainNavigation) {
        self.navigator = navigator
    }
    
    func transform(_ input: Input) -> Output {
        let didLoginSubject = PublishSubject<Bool>()
        
        input.viewDidAppearTrigger
            .map {
                let isLoggedIn = UserDefaults.standard.isLoggedIn
                print(isLoggedIn)
                return isLoggedIn
            }
            .bind(to: didLoginSubject)
            .disposed(by: disposeBag)
        
        didLoginSubject.subscribe { [weak self] didLoggedIn in
            if didLoggedIn {
                self?.navigator.navigate(to: .conversataion)
            } else {
                self?.navigator.navigate(to: .login)
            }
        }.disposed(by: disposeBag)
        
        return Output(didLoggedIn: didLoginSubject.asDriver(onErrorJustReturn: false))
    }
    
}

extension MainViewModel {
    struct Input {
        let viewDidAppearTrigger: Observable<Void>
    }
    
    struct Output {
        let didLoggedIn: Driver<Bool>
    }
}
