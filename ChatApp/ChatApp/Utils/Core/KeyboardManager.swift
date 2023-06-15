//
//  KeyboardManager.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 01/06/2023.
//

import Foundation
import IQKeyboardManager

struct KeyboardManager {
    static func setup() {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 120
    }
}
