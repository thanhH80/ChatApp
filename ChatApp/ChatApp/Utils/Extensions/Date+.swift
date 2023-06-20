//
//  Date+.swift
//  ChatApp
//
//  Created by Thagion Jack on 20/06/2023.
//

import Foundation
import SwiftDate

public let hanoiRegion: Region = {
    return Region(calendar: Calendars.gregorian, zone: Zones.asiaHoChiMinh, locale: Locales.vietnamese)
}()

public let fullVNDateFormatter: String = {
    return "dd/MM/yyy"
}()

public let shortVNDateFormatter: String = {
    return "dd/MM"
}()

public let timeFormat: String = {
    return "hh:mm"
}()

public let dateAndTimeFormat: String = {
    return "dd/MM/yyy 'at' HH:mm"
}()

extension Date {
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func getToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.component(.day, from: date)
        return today
    }
}
