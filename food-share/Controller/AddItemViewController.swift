//
//  AddItemViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 24/11/2021.
//
import UIKit

class AddItemViewController: UIViewController {
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var validUntilTextView: UITextField!
    
    var pickerView = UIPickerView()
    var datePicker = UIDatePicker()
    
    let categories = ["Fruit", "Vegetables", "Dairy", "Lactose free", "Grains", "Meat", "Fish", "Nonalcoholic beverages", "Alcohol", "Herbs", "Meals", "Desserts", "Baby food", "Cat food", "Dog food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCategoryPicker()
        setUpDatePicker()
    }
    
    func setUpCategoryPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextView.inputView = pickerView
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
