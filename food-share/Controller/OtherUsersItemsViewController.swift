//
//  OtherUsersItemsViewController.swift
//  food-share
//
//  Created by Karen on 12/01/2022.
//

import UIKit
import Firebase
import Lottie

class OtherUsersItemsViewController: UIViewController  {
    private let db = Firestore.firestore()
    let animationView = AnimationView()

    @IBOutlet weak var otherItemsCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    var tappedItem: UserItem!
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
        tappedItem = OtherItems.itemList[indexPath.row]
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
        return OtherItems.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherCollectionViewCell", for: indexPath) as! OtherCollectionViewCell
        
        cell.setup(with: OtherItems.itemList[indexPath.row])
        return cell
    }
    //set up animation
//    private func setUpAnimation() {
//        animationView.animation = Animation.named("loading")
//        switch traitCollection.userInterfaceStyle {
//                case .light, .unspecified:
//                    animationView.backgroundColor = .white
//                case .dark:
//                    animationView.backgroundColor = .black
//        @unknown default:
//            animationView.animation = Animation.named("loading")
//            animationView.backgroundColor = .white
//        }
//        
//        animationView.frame = view.bounds
//        animationView.center = view.center
//        animationView.contentMode = .scaleAspectFit
//        
//        animationView.loopMode = .repeat(3)
//        animationView.play()
//        view.addSubview(animationView)
//    }
    
}

extension OtherUsersItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 135)
    }
}
