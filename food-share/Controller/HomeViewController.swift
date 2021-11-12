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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.authenticateUserAndLoadHome()
            }
        }
        
        justLabel.text = Auth.auth().currentUser?.uid
        
        // Do any additional setup after loading the view.
        
        //set up navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signOutAlert))
    }
    
    func authenticateUserAndLoadHome() {
        let authNavigation = storyboard?.instantiateViewController(withIdentifier: "AuthVC") as! ViewController
        authNavigation.isModalInPresentation = true //if set to true, the user is not able to dismiss the presented controller by swiping down
        DispatchQueue.main.async {
            self.present(authNavigation, animated: true, completion: nil)
        }
    }
    
    @objc func signOutAlert() {
        let signOutAlert = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        signOutAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: signOut))
        signOutAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(signOutAlert, animated: true)
    }
    
    func signOut(alert: UIAlertAction!) {
        do {
            try Auth.auth().signOut()
        } catch _ {
            justLabel.text = "Error signing out"
        }
        authenticateUserAndLoadHome()
    }
}

