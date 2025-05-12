//
//  InputValidator.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import Foundation

// MARK: - Input validation service
struct InputValidationService {
    private enum RegexPattern {
        static let numericCheck = "^\\d+$"
        static let emailCheck = "^(?=.{6,100}$)([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$"
        static let latinLetterCheck = "^[a-zA-Z'’\\- ]+$"
        static let numbersAndDashesCheck = "^[0-9-]*$"
        static let uppercaseLatinAndNumbersCheck = "^[A-Z0-9]+$"
    }
    
    // MARK: - Validation type
    enum ValidationType {
        case numeric
        case email
        case latinLetter
        case numbersAndDashes
        case uppercaseLatinAndNumbers

        var pattern: String {
            switch self {
            case .numeric: RegexPattern.numericCheck
            case .email: RegexPattern.emailCheck
            case .latinLetter: RegexPattern.latinLetterCheck
            case .numbersAndDashes: RegexPattern.numbersAndDashesCheck
            case .uppercaseLatinAndNumbers: RegexPattern.uppercaseLatinAndNumbersCheck
            }
        }
    }
    
    // MARK: - Validation method
    static func isValid(_ string: String, for type: ValidationType) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type.pattern)
        return predicate.evaluate(with: string)
    }
}
