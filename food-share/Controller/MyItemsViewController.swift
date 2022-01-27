//
//  MyItemsViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 08/12/2021.
//

import UIKit
import Firebase
import Lottie

class MyItemsViewController: UIViewController, UISearchResultsUpdating  {
    
    private let db = Firestore.firestore()
    let animationView = AnimationView()
    
    private let searchController = UISearchController()
    
    @IBOutlet var myItemsCollectionView: UICollectionView!
    
    private var userItemsList: Array<UserItem> = UserItems.itemList
    private var filterCondition: NSRegularExpression = NSRegularExpression(".*")
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear func")
        //setup searchbar
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    var tappedItem: UserItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpAnimation
        CustomAnimation.setUp(view: view, animationView: animationView, frequency: 2, type: "loading")
        
        myItemsCollectionView.delegate = self
        myItemsCollectionView.dataSource = self
        myItemsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.animationView.stop()
            self.animationView.isHidden = true
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //self.myItemsCollectionView.reloadData()
        guard let text = searchController.searchBar.text else {
            return
        }
        self.filterCondition = NSRegularExpression("^\(text).*")
        
        self.userItemsList = UserItems.itemList.filter({ item in
            filterCondition.matches("\(item.getname())")
        })

        self.myItemsCollectionView.reloadData()
        print(text)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
        tappedItem = userItemsList[indexPath.row]
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

extension MyItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userItemsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        
        cell.setup(with: userItemsList[indexPath.row])
        return cell
    }
    
    //set up animation
    private func setUpAnimation() {
        //animationView.animation = Animation.named("")
        animationView.animation = Animation.named("loading")
        switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    animationView.backgroundColor = .white
                case .dark:
                    animationView.backgroundColor = .black
        @unknown default:
            animationView.animation = Animation.named("loading")
            animationView.backgroundColor = .white
        }
        
        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .repeat(3)
        animationView.play()
        view.addSubview(animationView)
    }
    
}

extension MyItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400, height: 130)
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

