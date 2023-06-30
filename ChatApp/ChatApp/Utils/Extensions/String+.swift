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
    
    func removeSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func toDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "vie")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
