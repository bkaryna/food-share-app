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
import CoreLocation

class OtherUsersItemsViewController: UIViewController, UISearchResultsUpdating, CLLocationManagerDelegate {
    private let db = Firestore.firestore()
    let animationView = AnimationView()

    @IBOutlet weak var otherItemsCollectionView: UICollectionView!
    private let searchController = UISearchController()
    
    private var otherUsersItemsList: Array<UserItem> = OtherItems.itemList
    private var filterCondition: NSRegularExpression = NSRegularExpression(".*")
    private var tappedItem: UserItem!
    
    private var usersLocationlatitude: Double = 0.0
    private var usersLocationlongitude: Double = 0.0
    
    
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
        
        menu.selectionAction = { [self] index, title in
            if (index == 0) { //price low to high
                self.otherUsersItemsList = self.otherUsersItemsList.sorted{
                    $0.getPrice()<$1.getPrice()
                }
            } else if (index == 1) { //price high to low
                self.otherUsersItemsList = self.otherUsersItemsList.sorted{
                    $0.getPrice()>$1.getPrice()
                }
            } else if (index == 2) { //newest first
                self.otherUsersItemsList = self.otherUsersItemsList.sorted{
                    $0.getValidFromDate()<$1.getValidFromDate()
                }
            } else if (index == 3) { //closest to me
//                handleLocationPermissions()
                self.otherUsersItemsList = OtherItems.itemList.filter({ item in
                    item.getLocationName() != "" && (self.calculateDistanceInKilometers(latitude1: item.getLocationLatitude(), longitude1: item.getLocationLongitude(), latitude2: self.usersLocationlatitude, longitude2: self.usersLocationlongitude) < 50)
                })
            }
            
            self.otherItemsCollectionView.reloadData()
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
    
//    func handleLocationPermissions() {
//        // Get the current location permissions
//         let status = CLLocationManager.requestLocation()
//
//        // Handle each case of location permissions
//        switch status {
//            case .authorizedAlways:
//                getUsersCurrentLocation()
//            case .authorizedWhenInUse:
//                getUsersCurrentLocation()
//            case .denied:
//                showAlert(title: "Access denied", message: "Please allow access to location in phone Settings.")
//                return
//            case .notDetermined:
//                handleLocationPermissions()
//            case .restricted:
//                handleLocationPermissions()
//        }
//
//    }
    
    func getUsersCurrentLocation() {
        // Create a CLLocationManager and assign a delegate
        let locationManager = CLLocationManager()
        locationManager.delegate = self

        // Request a user’s location once
        locationManager.requestLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            usersLocationlatitude = location.coordinate.latitude
            usersLocationlongitude = location.coordinate.longitude
        }
    }
    
    func showAlert(title: String, message: String) {
        var dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        dialogMessage.addAction(okButton)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func calculateDistanceInKilometers(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) -> Double {
        //Haversine formula https://www.movable-type.co.uk/scripts/latlong.html
        //https://www.geeksforgeeks.org/program-distance-two-points-earth/
        
        let coordinate1 = CLLocation(latitude: latitude1, longitude: longitude1)
        let coordinate2 = CLLocation(latitude: latitude2, longitude: longitude2)
        
        let distanceKm = coordinate1.distance(from: coordinate2)/1000.0
        return distanceKm
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
