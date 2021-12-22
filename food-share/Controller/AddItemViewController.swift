//
//  AddItemViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 24/11/2021.
//
import UIKit
import Firebase
import Photos

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var validUntilTextView: UITextField!
    @IBOutlet weak var quantityTextView: UITextField!
    @IBOutlet weak var unitTextView: UITextField!
    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var itemPhotoImageView: UIImageView!
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser!.uid
    private let storage = Storage.storage().reference()
    
    @IBAction func publishButtonTapped(_ sender: Any) {
        let name = nameTextView.text
        let category = categoryTextView.text
    
        let validFrom = Styling.formatDate(Date.init(), "MMM dd, yyyy")
        
        let validUntil = validUntilTextView.text
        let quantity = quantityTextView.text! + " " + unitTextView.text!
        let location = locationTextView.text
        let description = descriptionTextView.text
        
        let itemDocumentRef = db.collection("Items").document(userID).collection("user-items").document()
        
        itemDocumentRef.setData([ "Name": name! as String, "Category": category! as String, "Valid from": validFrom as String, "Valid until": validUntil! as String, "Quantity": quantity, "Location": location! as String, "Description": description! as String ], merge: true)
        
        
        let storageRef = storage.child("\(userID)/images/items/\(itemDocumentRef.documentID).png")
        storageRef.putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                return
            }
            
            storageRef.downloadURL (completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                //for future reference
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                
            })
        })
    }
    
    var categoryPickerView = UIPickerView()
    var datePicker = UIDatePicker()
    var unitPickerView = UIPickerView()
    
    let categories = ["Fruit", "Vegetables", "Dairy", "Lactose free", "Grains", "Meat", "Fish", "Nonalcoholic beverages", "Alcohol", "Herbs", "Meals", "Desserts", "Baby food", "Cat food", "Dog food"]
    
    let units = ["item(s)", "piece(s)", "package(s)", "litre(s)", "kilogram(s)", "gram(s)", "carton(s)", "can(s)", "jar(s)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCategoryPicker()
        setUpDatePicker()
        setUpUnitPicker()
        
        Styling.buttonStyle(publishButton)
        Styling.buttonStyle(discardButton)
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
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        validUntilTextView.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let picker = UIImagePickerController()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) {
                    newStatus in
                    switch newStatus
                    {case .restricted:
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
                    }}
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
