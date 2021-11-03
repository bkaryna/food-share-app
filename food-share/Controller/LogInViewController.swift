//
//  LogInViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 29/10/2021.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn


class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var logInStackView: UIStackView!
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        
        //validate fields
        
        //sign in
        Auth.auth().signIn(withEmail: Validation.clearWhitespacesAndNewLines(emailTextField.text!), password: Validation.clearWhitespacesAndNewLines(passwordTextField.text!)) { (authResult, error) in
            
            if error != nil {
                Validation.showAndHideError(self.errorLabel, "Failed to log in")
            } else {
                self.transitionToHome()
            }
            
        }
    }
    
    
    @IBAction func LogInWithGoogleTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if (error != nil) {
                Validation.showAndHideError(errorLabel, "Failed to sign in with Google")
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                //Validation.showError(errorLabel, "Failed to sign in with Google")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    Validation.showAndHideError(self.errorLabel, error.localizedDescription)
                    return
                } else {
                    transitionToHome()
                }
            }
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Log in error", message: "Failed to sign in. Please try again", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let googleButton = GIDSignInButton(frame: CGRect(x: 100,
                                                         y: 100,
                                                         width: 200,
                                                         height: 60))
        
        googleButton.addTarget(self,action: #selector(LogInWithGoogleTapped(_:)),for: .touchUpInside)
        
        logInStackView.addArrangedSubview(googleButton)
        
        // Do any additional setup after loading the view.
    }
    
    
    func transitionToHome() {
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
