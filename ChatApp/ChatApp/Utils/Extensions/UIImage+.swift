//
//  UIImage+.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 02/06/2023.
//

import Foundation
import UIKit

extension UIImageView {
    func makeCircle(withBorderColor borderColor: UIColor) {
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}
