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
    private var location: [String:Double]
    private var locationName: String
    private var description: String
    private var price: Double
    
    init (id: String, owner: String, name: String, dateFrom: String, dateUntil: String, category: String, price: Double, quantity: String, unit: String, location: [String:Double], locationName: String, description: String) {
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
        self.locationName = locationName
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
    
    func getLocationName() -> String {
        return self.locationName
    }
    
    func getLocationLatitude() -> Double {
        return self.location["latitude"]!
    }
    
    func getLocationLongitude() -> Double {
        return self.location["longitude"]!
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getPrice() -> Double {
        return self.price
    }
}
