//
//  LogInViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 29/10/2021.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        
        //validate fields
        
        //sign in
        Auth.auth().signIn(withEmail: Validation.clearWhitespacesAndNewLines(emailTextField.text!), password: Validation.clearWhitespacesAndNewLines(passwordTextField.text!)) { (authResult, error) in
            
            if error != nil {
                Validation.showError(self.errorLabel, "Failed to sign in")
            } else {
                self.transitionToHome()
            }
          
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func transitionToHome() {
        //storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController)
        let homeViewController = storyboard?.instantiateViewController(identifier: "HomeVC") as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
