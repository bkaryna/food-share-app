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
        let docRef = db.collection("Items").document(userID!)
        let storage = Storage.storage().reference()
        
        db.collection("Items").document(userID!).collection("user-items")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                DispatchQueue.global().async {
                    itemList = documents.map { queryDocumentSnapshot -> UserItem in
                        let data = queryDocumentSnapshot.data()
                        let _id = queryDocumentSnapshot.documentID as? String ?? ""
                        let _name = data["Name"] as? String ?? ""
                        let _dateFrom = data["Valid from"] as? String ?? ""
                        let _dateUntil = data["Valid until"] as? String ?? ""
                        var itemImage = URL(string: "https://www.wfp.org/sites/default/files/styles/impact_image/public/2017-01/SOM_20150614_WFP-Laila_Ali_5556.jpg?itok=Ef1CTnPL")
                        
                        return UserItem(id: _id, owner: userID!, name: _name, dateFrom: _dateFrom, dateUntil: _dateUntil)
                    }
                    
                    for item in itemList {
                        print("<Name: \(item.getname()) \t Id: \(item.getID()) \t dateFrom: \(item.getValidFromDate()) \t dateUntil: \(item.getValidUntilDate())\n")
                    }
                }
            }
    }
}
