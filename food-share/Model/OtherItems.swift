//
//  OtherItems.swift
//  food-share
//
//  Created by Karen on 12/01/2022.
//

import Foundation
import FirebaseAuth
import Firebase

struct OtherItems {
    static var itemList: Array<UserItem> = Array()
    
    static func getOtherItemsList() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid
        
        db.collection("Items").getDocuments { querySnapshot, error in
            if error != nil {
                print("Failed to fetch user list")
            } else {
                for document in querySnapshot!.documents {
                    print("\n\n document: \(document.documentID)\t\t\tuserI: \(userID)\n\n")
                    if (document.documentID != userID)
{                    db.collection("Items").document(document.documentID).collection("user-items")
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
                                    
                                    return UserItem(id: _id, owner: document.documentID, name: _name, dateFrom: _dateFrom, dateUntil: _dateUntil, category: _category, quantity: _quantity, unit: _unit, location: _location, description: _description)
                                }
                                
                                for item in itemList {
                                    print("<Name: \(item.getname()) \t Id: \(item.getID()) \t dateFrom: \(item.getValidFromDate()) \t dateUntil: \(item.getValidUntilDate())\n")
                                }
                            }
                        }}
                }
            }
        }
    }
}
