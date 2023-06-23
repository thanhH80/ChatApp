//
//  NibLoadableView.swift
//  PregCare
//
//  Created by Jack Lewis on 20/12/2022.
//

import UIKit

protocol NibLoadableView: AnyObject { }

extension NibLoadableView where Self: UIView {
    
    static var nibName: String {
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadableView { }
extension UICollectionViewCell: NibLoadableView { }
extension UITableViewHeaderFooterView: NibLoadableView { }
