//
//  AddItemViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 24/11/2021.
//
import UIKit
import Firebase

class AddItemViewController: UIViewController {
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var validUntilTextView: UITextField!
    @IBOutlet weak var quantityTextView: UITextField!
    @IBOutlet weak var unitTextView: UITextField!
    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    @IBAction func publishButtonTapped(_ sender: Any) {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        
        let name = nameTextView.text
        let category = categoryTextView.text
        let validUntil = validUntilTextView.text
        let quantity = quantityTextView.text! + " " + unitTextView.text!
        let location = locationTextView.text
        let description = descriptionTextView.text
        
        db.collection("Items").document(userID).collection("user-items").document().setData([ "Name": name! as String, "Category": category! as String, "Good until": validUntil! as String, "Quantity": quantity, "Location": location! as String, "Description": description! as String ], merge: true)
    }
    
    var categoryPickerView = UIPickerView()
    var datePicker = UIDatePicker()
    var unitPickerView = UIPickerView()
    
    let categories = ["Fruit", "Vegetables", "Dairy", "Lactose free", "Grains", "Meat", "Fish", "Nonalcoholic beverages", "Alcohol", "Herbs", "Meals", "Desserts", "Baby food", "Cat food", "Dog food"]
    
    let units = ["piece(s)", "package(s)", "litre(s)", "kilogram(s)", "gram(s)", "carton(s)", "can(s)", "jar(s)"]
    
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
}

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
}
