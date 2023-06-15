//
//  ColorConstant.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 31/05/2023.
//

import UIKit

extension UIColor {
    static let blue6A9CFD = UIColor(named: "6A9CFD") ?? UIColor.hex("6A9CFD")
    static let blueAEE4FF = UIColor(named: "AEE4FF") ?? UIColor.hex("AEE4FF")
    
    static let pinkFEE5E1 = UIColor(named: "FEE5E1") ?? UIColor.hex("FEE5E1")
    static let pinkFFB8D0 = UIColor(named: "FFB8D0") ?? UIColor.hex("FFB8D0")
    static let pinkFFBFB3 = UIColor(named: "FFBFB3") ?? UIColor.hex("FFBFB3")
    
    static let grayLastCECECE = UIColor(named: "CECECE") ?? UIColor.hex("CECECE")
    static let grayMain575757 = UIColor(named: "575757") ?? UIColor.hex("575757")
    static let graySecond848484 = UIColor(named: "848484") ?? UIColor.hex("848484")
    
    
  
}

extension UIColor {
    static var navigationGradientBackgroundBottomColor: UIColor {
        return .white
    }
    static var appBackground: UIColor {
        return .graySecond848484
    }
}
