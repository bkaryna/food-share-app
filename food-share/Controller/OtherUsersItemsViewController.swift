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
        menu.dataSource = ["Price low to high", "Price high to low", "Newest first", "Closest to me"]
        return menu
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersCurrentLocation()
        updateSearchResults(for: searchController)
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
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        label.textAlignment = .center
        label.text = "Sort"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "AccentColor")
        

        menuView.addSubview(label)
        navigationController?.navigationBar.topItem?.titleView = menuView
        
        guard let topMenuView = navigationController?.navigationBar.topItem?.titleView else {
            return
        }
        
        //menu.width = view.frame.width*0.5
        menu.anchorView = otherItemsCollectionView
        
        switch view.traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    menu.backgroundColor = .white
                    menu.textColor = .black
                case .dark:
                    menu.backgroundColor = .black
                    menu.textColor = .white
        @unknown default:
            menu.backgroundColor = .white
            menu.textColor = .black
        }
        
        menu.selectionBackgroundColor = UIColor(named: "AccentColor")!
        menu.selectedTextColor = .black
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(topMenuBarTapped))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        topMenuView.addGestureRecognizer(gesture)
        
        menu.selectionAction = { [self] index, title in
            if (index == 0) { //price low to high
                self.otherUsersItemsList = OtherItems.itemList.sorted{
                    $0.getPrice()<$1.getPrice()
                }
            } else if (index == 1) { //price high to low
                self.otherUsersItemsList = OtherItems.itemList.sorted{
                    $0.getPrice()>$1.getPrice()
                }
            } else if (index == 2) { //newest first
                self.otherUsersItemsList = OtherItems.itemList.sorted{
                    $0.getValidFromDate()>$1.getValidFromDate()
                }
            } else if (index == 3) { //closest to me
                //filter --> to consider
//                self.otherUsersItemsList.removeAll(where: {$0.getLo cationName().isEmpty || (self.calculateDistanceInKilometers(latitude1: $0.getLocationLatitude(), longitude1: $0.getLocationLongitude(), latitude2: self.usersLocationlatitude, longitude2: self.usersLocationlongitude)) > 50.0})
                //sorting
                self.otherUsersItemsList = OtherItems.itemList.sorted{
                    calculateDistanceInKilometers(latitude1: $0.getLocationLatitude(), longitude1: $0.getLocationLongitude(), latitude2: usersLocationlatitude, longitude2: usersLocationlongitude) < calculateDistanceInKilometers(latitude1: $1.getLocationLatitude(), longitude1: $1.getLocationLongitude(), latitude2: usersLocationlatitude, longitude2: usersLocationlongitude)
                }
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
    
    func getUsersCurrentLocation() {
        // Create a CLLocationManager and assign a delegate
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
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
            
            print("-----my location-----\nlat: \(usersLocationlatitude)\nlong: \(usersLocationlongitude)")
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        return
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
        print("\n\tDistance: \(distanceKm)")
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
