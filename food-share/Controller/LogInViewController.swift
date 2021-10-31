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
                Validation.showError(self.errorLabel, "Failed to sign in")
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

          if let error = error {
            // ...
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                  let authError = error as NSError
//                  if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
//                    // The user is a multi-factor user. Second factor challenge is required.
//                    let resolver = authError
//                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
//                    var displayNameString = ""
//                    for tmpFactorInfo in resolver.hints {
//                      displayNameString += tmpFactorInfo.displayName ?? ""
//                      displayNameString += " "
//                    }
//                    self.showTextInputPrompt(
//                      withMessage: "Select factor to sign in\n\(displayNameString)",
//                      completionBlock: { userPressedOK, displayName in
//                        var selectedHint: PhoneMultiFactorInfo?
//                        for tmpFactorInfo in resolver.hints {
//                          if displayName == tmpFactorInfo.displayName {
//                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
//                          }
//                        }
//                        PhoneAuthProvider.provider()
//                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
//                                             multiFactorSession: resolver
//                                               .session) { verificationID, error in
//                            if error != nil {
//                              print(
//                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
//                              )
//                            } else {
//                              self.showTextInputPrompt(
//                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
//                                completionBlock: { userPressedOK, verificationCode in
//                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
//                                    .credential(withVerificationID: verificationID!,
//                                                verificationCode: verificationCode!)
//                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
//                                    .assertion(with: credential!)
//                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
//                                    if error != nil {
//                                      print(
//                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
//                                      )
//                                    } else {
//                                      self.navigationController?.popViewController(animated: true)
//                                    }
//                                  }
//                                }
//                              )
//                            }
//                          }
//                      }
//                    )
//                  } else {
//                    Validation.showError(self.errorLabel, error.localizedDescription)
//                    return
//                  }
//                  // ...
//                  return
//                }
                    transitionToHome()
            }
        }
        
        
        

        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let googleButton = GIDSignInButton(frame: CGRect(x: 100,
                                                         y: 100,
                                                         width: 200,
                                                         height: 60))
        
        googleButton.addTarget(self,action: #selector(LogInWithGoogleTapped(_:)),for: .touchUpInside)
        
        
        // TODO: allign the button properly
        logInStackView.addSubview(googleButton)

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
