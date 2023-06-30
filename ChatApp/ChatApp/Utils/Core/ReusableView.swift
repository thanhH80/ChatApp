//
//  ReusableView.swift
//  PregCare
//
//  Created by Jack Lewis on 20/12/2022.
//

import UIKit

protocol ReusableView: AnyObject { }

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UITableViewCell: ReusableView { }
extension UICollectionViewCell: ReusableView { }
extension UITableViewHeaderFooterView: ReusableView { }
