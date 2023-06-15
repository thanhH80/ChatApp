//
//  UIColor+.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 31/05/2023.
//

import Foundation
import UIKit

extension UIColor {
    
    class func hex(_ hexCode: String) -> UIColor {
        return UIColor.hex(hexCode, alpha: 1.0)
    }

    class func hex(_ hexCode: String, alpha: CGFloat) -> UIColor {
        guard hexCode.count == 6 else {
            return UIColor.gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexCode).scanHexInt64(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
