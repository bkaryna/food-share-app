//
//  OtherUsersItemsViewController.swift
//  food-share
//
//  Created by Karen on 12/01/2022.
//

import UIKit
import Firebase
import Lottie
import DropDown

class OtherUsersItemsViewController: UIViewController, UISearchResultsUpdating  {
    private let db = Firestore.firestore()
    let animationView = AnimationView()

    @IBOutlet weak var otherItemsCollectionView: UICollectionView!
    private let searchController = UISearchController()
    
    private var otherUsersItemsList: Array<UserItem> = OtherItems.itemList
    private var filterCondition: NSRegularExpression = NSRegularExpression(".*")
    private var tappedItem: UserItem!
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Price low to high", "Price high to low", "Newest first", "Close to me"]
        return menu
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
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
        
        let menuView = UIView(frame: navigationController?.navigationBar.frame ?? .zero)
        navigationController?.navigationBar.topItem?.titleView = menuView
        
        guard let topMenuView = navigationController?.navigationBar.topItem?.titleView else {
            return
        }
        
        //menu.width = view.frame.width*0.5
        menu.anchorView = topMenuView
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(topMenuBarTapped))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        topMenuView.addGestureRecognizer(gesture)
        
        menu.selectionAction = { index, title in
            if (index == 2) {
                self.otherUsersItemsList.sorted{
                    $0.getValidFromDate()<$1.getValidFromDate()
                }
                self.otherItemsCollectionView.reloadData()
            }
        }
    }
    
    @objc func topMenuBarTapped(){
        menu.show()
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
        return CGSize(width: 400, height: 145)
    }
}
