//
//  SignUpViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 29/10/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButtonAction: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    //check the fields and validate the data; return nil or error message
    func validateFields() -> String? {
        //check if all fields are filled in
        if Validation.stringEmpty(firstNameTextField.text!) || Validation.stringEmpty(lastNameTextField.text!) ||
            Validation.stringEmpty(emailTextField.text!) ||
            Validation.stringEmpty(passwordTextField.text!) {
            return "Please fill in all he required data"
        }
        
        //check password security
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Validation.passwordValid(cleanedPassword) == false {
            return "Please make sure your password meets the requirements"
        }
        
        return nil
    }
    
    
    
    @IBAction func SignUpTapped(_ sender: Any) {
        //fields validation
        let error = validateFields()

        if error != nil{
            Validation.showAndHideError(self.errorLabel, error!)
        }
        
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //user creation
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if err != nil {
                Validation.showAndHideError(self.errorLabel, "Error creating user")
            } else {
                let db = Firestore.firestore()
                db.collection("Users").document(result!.user.uid).setData([ "FirstName": firstName, "LastName": lastName ]) {(error) in
                    if error != nil {
                    // Show error message
                        Validation.showAndHideError(self.errorLabel, "Error saving user's data")
                    } else {
                        // Transition to the home screen
                        self.transitionToHome()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //disable auto fill for password field https://developer.apple.com/forums/thread/108085
        passwordTextField.textContentType = .oneTimeCode
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func transitionToHome() {
        //storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController)
        let homeTabsViewController = storyboard?.instantiateViewController(identifier: "HomeTabsVC") as? HomeTabsViewController
        
        view.window?.rootViewController = homeTabsViewController
        view.window?.makeKeyAndVisible()
    }

}
