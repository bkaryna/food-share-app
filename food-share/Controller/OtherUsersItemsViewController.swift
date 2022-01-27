//
//  OtherUsersItemsViewController.swift
//  food-share
//
//  Created by Karen on 12/01/2022.
//

import UIKit
import Firebase
import Lottie

class OtherUsersItemsViewController: UIViewController, UISearchResultsUpdating  {
    private let db = Firestore.firestore()
    let animationView = AnimationView()

    @IBOutlet weak var otherItemsCollectionView: UICollectionView!
    private let searchController = UISearchController()
    
    private var otherUsersItemsList: Array<UserItem> = OtherItems.itemList
    private var filterCondition: NSRegularExpression = NSRegularExpression(".*")
    private var tappedItem: UserItem!
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        self.otherItemsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setUpAnimation
        CustomAnimation.setUp(view: view, animationView: animationView, frequency: 2, type: "loading")
        
        otherItemsCollectionView.delegate = self
        otherItemsCollectionView.dataSource = self
        otherItemsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.animationView.stop()
            self.animationView.isHidden = true
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.otherItemsCollectionView.reloadData()
        guard let text = searchController.searchBar.text else {
            return
        }
        self.filterCondition = NSRegularExpression("^\(text).*")
        
        self.otherUsersItemsList = OtherItems.itemList.filter({ item in
            filterCondition.matches("\(item.getname())")
        })

        self.otherItemsCollectionView.reloadData()
        print(text)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
        tappedItem = otherUsersItemsList[indexPath.row]
        goToItemView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myItem" {
            let destinationController = segue.destination as! AddItemViewController
            destinationController.userItem = tappedItem
        }
    }
    
    func goToItemView() {
        guard let destinationController = self.storyboard?.instantiateViewController(identifier: "AddItemVC") as? AddItemViewController
        else {
            print("Failed to load vc")
            return
        }
        destinationController.userItem = tappedItem
        
        navigationController?.pushViewController(destinationController, animated: true)
    }
}

extension OtherUsersItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherUsersItemsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherCollectionViewCell", for: indexPath) as! OtherCollectionViewCell
        
        cell.setup(with: otherUsersItemsList[indexPath.row])
        return cell
    }
    
}

extension OtherUsersItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400, height: 130)
    }
}
