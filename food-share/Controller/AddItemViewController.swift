//
//  AddItemViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 24/11/2021.
//
import UIKit

class AddItemViewController: UIViewController {
    @IBOutlet weak var categoryTextView: UITextField!
    
    var pickerView = UIPickerView()
    
    let categories = ["Fruit", "Vegetables", "Dairy", "Lactose free", "Grains", "Meat", "Fish", "Nonalcoholic beverages", "Alcohol", "Herbs", "Meals", "Desserts", "Baby food", "Cat food", "Dog food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCountryPicker()
    }
    
    func setUpCountryPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextView.inputView = pickerView
    }
    
}

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    //title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextView.text = categories[row]
        categoryTextView.resignFirstResponder() //dismiss pickerview
    }
}
