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
        
        db.collection("Items").document(userID!).collection("user-items")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                DispatchQueue.main.async {
                    itemList = documents.map { queryDocumentSnapshot -> UserItem in
                        let data = queryDocumentSnapshot.data()
                        let _id = queryDocumentSnapshot.documentID as? String ?? ""
                        let _name = data["Name"] as? String ?? ""
                        let _date = data["Good until"] as? String ?? ""
                        
                        return UserItem(id: _id, name: _name, date: _date)
                    }
                    
                    for item in itemList {
                        print("<Name: \(item.getname()) \t Id: \(item.getID()) \t date: \(item.getValidUntilDate())\n")
                    }
                }
            }
    }
}
