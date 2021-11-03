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
    
    static func clearWhitespacesAndNewLines(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func stringEmpty(_ string: String) -> Bool {
        let clearedString = clearWhitespacesAndNewLines(string)
        
        if clearedString == "" {
            return true
        }
        return false
    }
    
    static func showAndHideError(_ label: UILabel, _ message: String) {
        label.text=message
        label.alpha=1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            label.alpha=0
        }
    }
}

