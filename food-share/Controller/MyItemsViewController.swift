//
//  MyItemsViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 08/12/2021.
//

import UIKit
import Firebase

class MyItemsViewController: UIViewController  {
    
    var testItem: UserItem = UserItem(id: "user-avatar-id", name: "Name", date: "Date")
    
    private let db = Firestore.firestore()
    
    @IBOutlet var myItemsCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myItemsCollectionView.delegate = self
        myItemsCollectionView.dataSource = self
        myItemsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
    
            print("You tapped me")
        }
}

extension MyItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserItems.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        
        cell.setup(with: UserItems.itemList[indexPath.row])
        return cell
    }
}

extension MyItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 135)
    }
}

