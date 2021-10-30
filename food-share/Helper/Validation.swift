//
//  Validation.swift
//  food-share
//
//  Created by Karyna Babenko on 29/10/2021.
//

import Foundation

class Validation {
    static func passwordValid(_ password: String) -> Bool {
        //regular expression
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}

