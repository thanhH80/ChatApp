//
//  ViewControllerBase.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import Foundation
import RxSwift

protocol ViewControllerBase {

    var disposeBag: DisposeBag { get set }
    func bindViewModel()
}
