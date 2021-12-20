//
//  UserItem.swift
//  food-share
//
//  Created by Karyna Babenko on 09/12/2021.
//

import Foundation

class UserItem {
    private var id: String
    private var name: String
    private var validUntil: String
    
    init (id: String, name: String, date: String) {
        self.id = id
        self.name = name
        self.validUntil = date
    }
    
    func getID() -> String {
        return self.id
    }
    
    func getname() -> String {
        return self.name
    }
    
    func getValidUntilDate() -> String {
        return self.validUntil
    }
}
