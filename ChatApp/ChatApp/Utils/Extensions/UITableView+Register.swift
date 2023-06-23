//
//  UITableView+Register.swift
//  PregCare
//
//  Created by Jack Lewis on 20/12/2022.
//

import UIKit

extension UITableView {
    
    func registerNib<T: UITableViewCell>(cellClass: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: bundle ?? Bundle(for: T.self))
        register(nib, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
        
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    public func dequeueCell<T: UITableViewCell>(ofType cellClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
    }
    
    public func dequeueCell<T: UITableViewCell>(ofType cellClass: T.Type) -> T {
           return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as! T
    }
    
    public func registerHeader<T: UITableViewHeaderFooterView>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    public func dequeueReusableHeaderView<T: UITableViewHeaderFooterView>(with type: T.Type) -> T {
        guard let header = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return header
    }
}
