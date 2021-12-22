//
//  UserItem.swift
//  food-share
//
//  Created by Karyna Babenko on 09/12/2021.
//

import Foundation
import UIKit

class UserItem {
    private var id: String
    private var name: String
    private var validFrom: String
    private var validUntil: String
    private var owner: String
    
    init (id: String, owner: String, name: String, dateFrom: String, dateUntil: String) {
        self.id = id
        self.owner = owner
        self.name = name
        self.validFrom = dateFrom
        self.validUntil = dateUntil
    }
    
    func getID() -> String {
        return self.id
    }
    
    func getOwner() -> String {
        return self.owner
    }
    
    func getname() -> String {
        return self.name
    }
    
    func getValidFromDate() -> String {
        return self.validFrom
    }
    
    func getValidUntilDate() -> String {
        return self.validUntil
    }
}
