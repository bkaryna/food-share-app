//
//  Database.swift
//  food-share
//
//  Created by Karen on 04/09/2022.
//

import Foundation
import Firebase

public func getUserDisplayName(userID documentID: String) -> String {
    let db = Firestore.firestore()
    var name: String = ""
    
    DispatchQueue.global().async {
        db.collection("Users").document(documentID)
            .getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    name = data?["Name"] as? String ?? ""
                } else {
                    print("Document does not exist")
                }
            }
    }
    print("NAME: \(name)")
    return name
}
