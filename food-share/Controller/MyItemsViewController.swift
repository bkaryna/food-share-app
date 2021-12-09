//
//  MyItemsViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 08/12/2021.
//

import UIKit
class MyItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var itemList: Array<UserItem> = Array()
    
    @IBOutlet var myItemsCollectionView: UICollectionView!
    
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

