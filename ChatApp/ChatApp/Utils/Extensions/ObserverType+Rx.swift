//
//  ObservableType+Rx.swift
//

import RxSwift
import RxCocoa

extension ObservableType {

    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
}

extension ObservableType where Element: Equatable {
    
    public func ignore(_ valuesToIgnore: Element...) -> Observable<Element> {
        return self.asObservable().filter { !valuesToIgnore.contains($0) }
    }
    
}
