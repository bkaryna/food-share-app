//
//  AddItemViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 24/11/2021.
//
import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import Photos
import Lottie
import LocationPicker
import MapKit

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var validUntilTextView: UITextField!
    @IBOutlet weak var quantityTextView: UITextField!
    @IBOutlet weak var unitTextView: UITextField!
    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var priceTextView: UITextField!
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var deactivateButton: UIButton!
    @IBOutlet weak var messageSellerButton: UIButton!
    
    @IBOutlet weak var itemPhotoImageView: UIImageView!
    @IBOutlet weak var priceSwitch: UISwitch!
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser!.uid
    private let storage = Storage.storage().reference()
    private let animationView = AnimationView()
    
    private var categoryPickerView = UIPickerView()
    private var datePicker = UIDatePicker()
    private var unitPickerView = UIPickerView()
    private var currencyPickerView = UIPickerView()
    
    @IBOutlet weak var freeSwitchStackView: UIStackView!
    
    var userItem: UserItem?
    private var chosenLocation: Location?
    
    private let categories = ["Fruit", "Vegetables", "Dairy", "Lactose free", "Grains", "Meat", "Fish", "Nonalcoholic beverages", "Alcohol", "Herbs", "Meals", "Desserts", "Baby food", "Cat food", "Dog food"]
    
    private let units = ["item(s)", "piece(s)", "package(s)", "litre(s)", "kilogram(s)", "gram(s)", "carton(s)", "can(s)", "jar(s)"]
    
    override func viewWillAppear(_ animated: Bool) {
        if userItem == nil {
            setUpAddItemView()
        } else {
            setUpEditItemView()
            if (userItem?.getOwner() != userID) {
                setUpViewOtherItemsView()
            }
        }
        
        Styling.buttonStyle(publishButton)
        Styling.buttonStyle(discardButton)
        Styling.buttonStyle(deleteButton)
        Styling.buttonStyle(deactivateButton)
        Styling.makeImageCornersRound(itemPhotoImageView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Add item vc loaded with data: \(userItem?.getname())")
    }
    
    @IBAction func publishButtonTapped(_ sender: Any) {
        let name = nameTextView.text
        let category = categoryTextView.text
        
        let validFrom = Styling.formatDate(Date.init(), "dd MMM yyyy")
        
        let validUntil = validUntilTextView.text
        let quantity = quantityTextView.text!
        let unit = unitTextView.text!
        let description = descriptionTextView.text
        
        var price: String = ""
        if (priceSwitch.isOn || priceTextView.text == "") {
            price = "0"
        } else {
            let priceFormatted = priceTextView.text!.replacingOccurrences(of: ",", with: ".")
            price = priceTextView.text!
        }
        
        
        var userLocation: [String:Double] = ["latitude": (chosenLocation?.coordinate.latitude ?? 0.0) , "longitude": (chosenLocation?.coordinate.longitude ?? 0.0) ]
        var locationName: String = chosenLocation?.name ?? ""
        
        var itemDocumentRef: DocumentReference
        
        if (self.userItem == nil) {
            itemDocumentRef = db.collection("Items").document(userID).collection("user-items").document()
            
            itemDocumentRef.setData([ "Name": name! as String, "Category": category! as String, "Valid from": validFrom as String, "Valid until": validUntil! as String, "Price": price, "Quantity": quantity, "Unit": unit as String, "Location": userLocation, "LocationName": locationName, "Description": description! as String ], merge: true)
        } else {
            itemDocumentRef = db.collection("Items").document(userID).collection("user-items").document((self.userItem?.getID())!)
            itemDocumentRef.updateData([ "Name": name! as String, "Category": category! as String, "Valid from": validFrom as String, "Valid until": validUntil! as String, "Price": price, "Quantity": quantity, "Unit": unit as String, "Location": userLocation, "LocationName": locationName,  "Description": description! as String])
        }
        
        if (self.itemPhotoImageView.image != nil && self.itemPhotoImageView.image?.isEqual(UIImage(systemName: "photo.fill")) == false) {
            
            let storageRef = storage.child("\(userID)/images/items/\(itemDocumentRef.documentID).png")
            storageRef.putData(imageData, metadata: nil, completion: {_, error in
                guard error == nil else {
                    return
                }
                
                storageRef.downloadURL (completion: { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    //console output
                    let urlString = url.absoluteString
                    print("Download URL: \(urlString)")
                    
                })
                
            })
        }
        
        CustomAnimation.setUp(view: view, animationView: animationView, frequency: 2, type: "done")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.animationView.stop()
            self.animationView.isHidden = true
            self.userItem = nil
            _ = self.navigationController?.popToRootViewController(animated: true)
//            self.navigationController?.pushViewController(MyItemsViewController(), animated: true)
        }
    }
    
    @IBAction func freeSwitchTapped(_ sender: UISwitch) {
        if (sender.isOn == true) {
            priceTextView.isHidden = true
        } else {
            priceTextView.isHidden = false
        }
    }
    
    @IBAction func discardButtonTapped(_ sender: Any) {
        _ = self.navigationController?.popToRootViewController(animated: true)
        userItem = nil
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        print("\n\nownerID: \(userItem!.getOwner()) \t itemID: \(userItem!.getID())\n\n")
        db.collection("Items").document("\(userItem!.getOwner())").collection("user-items").document("\(userItem!.getID())").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                CustomAnimation.setUp(view: self.view, animationView: self.animationView, frequency: 2, type: "done")
                print("Document successfully removed!")
            }
        }
    }
    
    @IBAction func deactivateButtonTapped(_ sender: Any) {
        
        let date = Date().dayBefore
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        let newFormattedDate = dateFormatter.string(from: date)
        
        let itemDocumentRef = db.collection("Items").document(userID).collection("user-items").document((self.userItem?.getID())!)
        
        itemDocumentRef.updateData([ "Valid until": newFormattedDate as String])
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func chooseLocationButtonTapped(_ sender: Any) {
        locationTextView.isHidden = false
        let locationPicker = LocationPickerViewController()
    
        // you can optionally set initial location
//        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.331686, longitude: -122.030656), addressDictionary: nil)
//        let location = Location(name: "1 Infinite Loop, Cupertino", location: nil, placemark: placemark)
//        locationPicker.location = location

        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true

        // default: navigation bar's `barTintColor` or `UIColor.white`
        locationPicker.currentLocationButtonBackground = .blue

        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true

        locationPicker.mapType = .standard // default: .Hybrid

        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        locationPicker.selectCurrentLocationInitially = true

        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"

        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"

        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600

        locationPicker.completion = { location in
            // do some awesome stuff with location
            
            if (location != nil){
                self.chosenLocation = location!
                self.locationTextView.text = location?.title
            }
        }

        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    func setUpCategoryPicker() {
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        categoryTextView.inputView = categoryPickerView
    }
    
    func setUpUnitPicker() {
        unitPickerView.delegate = self
        unitPickerView.dataSource = self
        
        unitTextView.inputView = unitPickerView
    }
    
    func setUpDatePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonTapped))
        toolBar.setItems([doneButton], animated: true)
        
        validUntilTextView.inputAccessoryView = toolBar
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        validUntilTextView.inputView = datePicker
    }
    
    @objc func doneButtonTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        validUntilTextView.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        handlePhotoAccessPermissions()
    }
    
    private var image: UIImage = UIImage()
    private var imageData: Data = Data()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!
        imageData = image.pngData()!
        itemPhotoImageView.image = UIImage(data: imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
    
    func setUpUserItemData() {
        nameTextView.text = userItem?.getname()
        categoryTextView.text = userItem?.getCategory()
        validUntilTextView.text = userItem?.getValidUntilDate()
        quantityTextView.text = userItem?.getQuantity()
        unitTextView.text = userItem?.getUnit()
        locationTextView.text = userItem?.getLocationName()
        descriptionTextView.text = userItem?.getDescription()
        priceTextView.text = "\(userItem?.getPrice() ?? "0.0")"
    }
    
    func handlePhotoAccessPermissions() {
        var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let picker = UIImagePickerController()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                self.handlePhotoAccessPermissions()
            case .restricted:
                // The system restricted this app's access.
                DispatchQueue.main.async {
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    picker.allowsEditing = true
                    self.present(picker, animated: true)
                }
            case .denied:
                DispatchQueue.main.async {
                    readWriteStatus = .notDetermined
                    self.informationAlert(title: "Access denied", message: "Please allow access to photo library.")
                }
            case .authorized:
                DispatchQueue.main.async {
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    picker.allowsEditing = true
                    self.present(picker, animated: true)
                }
            case .limited:
                DispatchQueue.main.async {
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    picker.allowsEditing = true
                    self.present(picker, animated: true)
                }
            @unknown default:
                fatalError()
            }
        }
    }
    
    func setUpAddItemView() {
        deleteButton.isHidden = true
        priceTextView.isHidden = true
        messageSellerButton.isHidden = true
        
        if (chosenLocation != nil) {
            locationTextView.isHidden = false
        } else {
            locationTextView.isHidden = true
        }
        
        setUpCategoryPicker()
        setUpDatePicker()
        setUpUnitPicker()
        deactivateButton.isHidden = true
        
        locationTextView.isEnabled = false
    }
    
    func setUpEditItemView() {
        DispatchQueue.global().async {
            let ref = self.storage.child("\(self.userItem!.getOwner())/images/items/\(self.userItem!.getID()).png")
            
            ref.downloadURL { url, error in
                if (error != nil) {
                    try? self.itemPhotoImageView.image = UIImage(systemName: "photo.fill")
                    print("image fetching - error")
                } else {
                    try? self.itemPhotoImageView.image = UIImage(data: Data(contentsOf:url!))
                }
            }
        }
        setUpUserItemData()
        deactivateButton.isHidden = false
        deleteButton.isHidden = false
        messageSellerButton.isHidden = true
        
        if (userItem?.getLocationName() != nil || userItem?.getLocationName() != "") {
            locationTextView.isHidden = false
            locationTextView.text = userItem?.getLocationName()
        } else {
            locationTextView.isHidden = true
        }
        
        if (userItem?.getPrice() == "0" || userItem?.getPrice() == "0.0" || userItem?.getPrice() == nil) {
            priceSwitch.isOn = true
            priceTextView.isHidden = true
        } else {
            priceSwitch.isOn = false
        }
        
        setUpCategoryPicker()
        setUpDatePicker()
        setUpUnitPicker()
        
        
        locationTextView.isEnabled = false
    }
    
    func setUpViewOtherItemsView() {
        locationButton.isHidden = true
        publishButton.isHidden = true
        discardButton.isHidden = true
        deleteButton.isHidden = true
        editPhotoButton.isHidden = true
        messageSellerButton.isHidden = false
        
        nameTextView.isEnabled = false
        categoryTextView.isEnabled = false
        validUntilTextView.isEnabled = false
        quantityTextView.isEnabled = false
        unitTextView.isEnabled = false
        unitPickerView.isMultipleTouchEnabled = false
        descriptionTextView.isEnabled = false
        locationTextView.isHidden = false
        validUntilTextView.text = "Valid until: \(userItem?.getValidUntilDate() ?? "")"
        
        if (userItem?.getPrice() == "0" || userItem?.getPrice() == "0.0") {
            priceTextView.text = "Price: free"
        } else {
            priceTextView.text = "Price: \(userItem?.getPrice()) zl"
        }
        priceTextView.isEnabled = false
        priceTextView.isHidden = false
        locationTextView.text = userItem?.getLocationName()
        
        freeSwitchStackView.isHidden = true
        deactivateButton.isHidden = true
    }
}


// categoty&date picker extensions
extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView==categoryPickerView) {
            return categories.count
        } else {
            return units.count
        }
    }
    
    //title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView==categoryPickerView) {
            return categories[row]
        } else {
            return units[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView==categoryPickerView) {
            categoryTextView.text = categories[row]
            categoryTextView.resignFirstResponder() //dismiss pickerview
        } else {
            unitTextView.text = units[row]
            unitTextView.resignFirstResponder() //dismiss pickerview
        }
    }
    
    func informationAlert(title: String, message: String) {
        let informationAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        informationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(informationAlert, animated: true)
    }
}
