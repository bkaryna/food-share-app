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

    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    
    //check the fields and validate the data; return nil or error message
    func validateFields() -> String? {
        //check if all fields are filled in
        if FirstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || LastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            PasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all he required data"
        }
        
        //check password security
        let cleanedPassword = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Validation.passwordValid(cleanedPassword) == false {
            return "Please make sure your password meets the requirements"
        }
        
        return nil
    }
    
    
    
    @IBAction func SignUpTapped(_ sender: Any) {
//        fields validation
//        let error = validateFields()
//
//        if error != nil{
//            showError(error!)
//        }
        
        let firstName = FirstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = LastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = EmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //user creation
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if err != nil {
                self.showError("Error creating user")
            } else {
                let db = Firestore.firestore()
                db.collection("Users").document(result!.user.uid).setData([ "FirstName": firstName, "LastName": lastName ]) {(error) in
                    if error != nil {
                    // Show error message
                        self.showError("Error saving user data")
                    }
                }
                
                // Transition to the home screen
                self.transitionToHome()
            }
        }
        
        //go to home screen
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showError(_ error: String) {
        ErrorLabel.text=error;
        ErrorLabel.alpha=1
    }
    
    func transitionToHome() {
        //storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController)
        let homeViewController = storyboard?.instantiateViewController(identifier: "HomeVC") as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

}
