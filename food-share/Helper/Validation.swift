//
//  Validation.swift
//  food-share
//
//  Created by Karyna Babenko on 29/10/2021.
//

import Foundation
import UIKit

class Validation {
    static func passwordValid(_ password: String) -> Bool {
        //regular expression example
        // TODO: create own regex
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func stringEmpty(_ string: String) -> Bool {
        if string.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return true
        }
        return false
    }
    
    static func showError(_ label: UILabel, _ message: String) {
        label.text=message
        label.alpha=1
    }
}

