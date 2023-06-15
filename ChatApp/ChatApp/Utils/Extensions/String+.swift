//
//  String+.swift
//  RealTimeChat
//
//  Created by Thagion Jack on 03/06/2023.
//

import UIKit

extension String {
    /// when set Email address like key
    static func makeSafe(_ string: String) -> String {
        var safeString = string.replacingOccurrences(of: "@", with: "-")
        safeString = safeString.replacingOccurrences(of: ".", with: "-")
        return safeString
    }
}
