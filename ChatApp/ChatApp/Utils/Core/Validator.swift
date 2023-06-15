//
//  Validator.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//
import Foundation

enum ValidationError: Error {
    case nameLengthOver
    case invalidEmailCharacter
    case invalidPassword
    case invalidConfirmPass
    case wrongPassword
    case wrongEmail
    case wrongPhoneNumber
    case notEmpty
}

extension ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case.invalidEmailCharacter:
            return NSLocalizedString(CustomAlertMessage.invalidEmailCharacter.text, comment: "")
        case .nameLengthOver:
            return NSLocalizedString(CustomAlertMessage.nameLengthOver.text, comment: "")
        case .invalidPassword:
            return NSLocalizedString(CustomAlertMessage.invalidPassword.text, comment: "")
        case.invalidConfirmPass:
            return NSLocalizedString(CustomAlertMessage.invalidConfirmPass.text, comment: "")
        case.wrongPassword:
            return NSLocalizedString(CustomAlertMessage.wrongPassword.text, comment: "")
        case.wrongEmail:
            return NSLocalizedString(CustomAlertMessage.wrongEmail.text, comment: "")
        case.wrongPhoneNumber:
            return NSLocalizedString(CustomAlertMessage.wrongPhoneNumber.text, comment: "")
        case .notEmpty:
            return NSLocalizedString(CustomAlertMessage.notEmpty.text, comment: "")
        }
    }
}

struct Rule<Value> {
    let valid: (Value) throws -> Void
}

extension Rule where Value == String {
    
    static let nameLengthOver120 = Rule { value in
        let valid = value.count <= 120
        guard valid else {
            throw ValidationError.nameLengthOver
        }
    }
    
    static let passwordLengthOver = Rule { value in
        let valid = value.count < 6 || value.count >= 32
        guard valid else {
            throw ValidationError.invalidPassword
        }
    }
}

class Validator {
   static func validate<Value>(value: Value, withRule rule: Rule<Value>) throws {
       try rule.valid(value)
   }
}
