//
//  Storyboard+.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit

extension UIStoryboard {
    
    class func storyboard(_ storyboardName: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboardName.rawValue, bundle: Bundle(for: AppDelegate.self))
    }
    
    func instantiateViewController<T>(ofType type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }

    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
}
