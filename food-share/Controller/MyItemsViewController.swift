//
//  MyItemsViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 08/12/2021.
//

import UIKit
import Firebase

class MyItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var itemList: Array<UserItem> = Array()
    private let db = Firestore.firestore()
    
    @IBOutlet var myItemsCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        let userID = Auth.auth().currentUser?.uid
        let docRef = db.collection("Items").document(userID!)
        
        db.collection("Items").document(userID!).collection("user-items")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                self.itemList = documents.map { queryDocumentSnapshot -> UserItem in
                    let data = queryDocumentSnapshot.data()
                    let _id = queryDocumentSnapshot.documentID as? String ?? ""
                    let _name = data["Name"] as? String ?? ""
                    let _date = data["Good until"] as? String ?? ""
                    
                    return UserItem(id: _id, name: _name, date: _date)
                }
                
                for item in self.itemList {
                    print("<Name: \(item.getname()) \t Id: \(item.getID()) \t date: \(item.getValidUntilDate())\n")
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 120)
        myItemsCollectionView.collectionViewLayout = layout
        
        myItemsCollectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        myItemsCollectionView.delegate = self
        myItemsCollectionView.dataSource = self
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.configure(with: UIImage(named: "user-avatar")!, with: "Some label", with: "SomeDate")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 120)
    }
    
    func getUserIteamsFromDatabase() {
        
    }
}

