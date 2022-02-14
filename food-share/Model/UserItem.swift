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
    
    private var category: String
    private var quantity: String //consider changing to Float
    private var unit: String
    private var location: String
    private var description: String
    private var price: String
    
    init (id: String, owner: String, name: String, dateFrom: String, dateUntil: String, category: String, price: String, quantity: String, unit: String, location: String, description: String) {
        self.id = id
        self.owner = owner
        self.name = name
        self.validFrom = dateFrom
        self.validUntil = dateUntil
        
        self.category = category
        self.quantity = quantity
        self.price = price
        self.unit = unit
        self.location = location
        self.description = description
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
    
    func getCategory() -> String {
        return self.category
    }
    
    func getQuantity() -> String {
        return self.quantity
    }
    
    func getUnit() -> String {
        return self.unit
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getPrice() -> String {
        return self.price
    }
}
