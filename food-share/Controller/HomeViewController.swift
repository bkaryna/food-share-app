//
//  HomeViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 12/11/2021.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    //testing purposes - will be deleted
    @IBOutlet weak var justLabel: UILabel!
    
    @IBAction func signOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch _ {
            justLabel.text = "Error signing out"
        }
        authenticateUserAndLoadHome()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.authenticateUserAndLoadHome()
            }
        }
        
        justLabel.text = Auth.auth().currentUser?.uid
        // Do any additional setup after loading the view.
    }
    
    func authenticateUserAndLoadHome() {
        let authNavigation = storyboard?.instantiateViewController(withIdentifier: "AuthVC") as! ViewController
        authNavigation.isModalInPresentation = true //if set to true, the user is not able to dismiss the presented controller by swiping down
        DispatchQueue.main.async {
            self.present(authNavigation, animated: true, completion: nil)
        }
    }
}

