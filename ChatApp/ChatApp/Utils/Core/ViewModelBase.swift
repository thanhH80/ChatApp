//
//  ViewModelBase.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
    var disposeBag: DisposeBag { get set }
}
