//
//  MyItemsViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 08/12/2021.
//

import UIKit
import Firebase
import Lottie

class MyItemsViewController: UIViewController  {
    private let db = Firestore.firestore()
    let animationView = AnimationView()
    
    @IBOutlet var myItemsCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
        tappedItem = UserItems.itemList[indexPath.row]
        
//        let vc = storyboard?.instantiateViewController(identifier: "AddItemVC") as! AddItemViewController
//        vc.modalPresentationStyle = .automatic
//        present(vc, animated: true)
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
        return UserItems.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        
        cell.setup(with: UserItems.itemList[indexPath.row])
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
        return CGSize(width: 350, height: 135)
    }
}

