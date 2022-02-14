//
//  UserItems.swift
//  food-share
//
//  Created by Karyna Babenko on 20/12/2021.
//

import Foundation
import FirebaseAuth
import Firebase

struct UserItems {
    static var itemList: Array<UserItem> = Array()
    
    static func getUserItemsList() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid
        
        db.collection("Items").document(userID!).collection("user-items")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                DispatchQueue.global().async {
                    itemList = documents.map { queryDocumentSnapshot -> UserItem in
                        let data = queryDocumentSnapshot.data()
                        let _id = queryDocumentSnapshot.documentID
                        let _name = data["Name"] as? String ?? ""
                        let _dateFrom = data["Valid from"] as? String ?? ""
                        let _dateUntil = data["Valid until"] as? String ?? ""
                        
                        let _category = data["Category"] as? String ?? ""
                        let _quantity = data["Quantity"] as? String ?? ""
                        let _unit = data["Unit"] as? String ?? ""
                        let _location = data["Location"] as? String ?? ""
                        let _description = data["Description"] as? String ?? ""
                        let _price = data["Price"] as? String ?? "0"
                        
                        return UserItem(id: _id, owner: userID!, name: _name, dateFrom: _dateFrom, dateUntil: _dateUntil, category: _category, price: _price, quantity: _quantity, unit: _unit, location: _location, description: _description)
                    }
                    
                    for item in itemList {
                        print("<Name: \(item.getname()) \t Id: \(item.getID()) \t dateFrom: \(item.getValidFromDate()) \t dateUntil: \(item.getValidUntilDate())\n")
                    }
                }
            }
    }
}
