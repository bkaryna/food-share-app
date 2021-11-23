//
//  HomeViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 12/11/2021.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { [self] auth, user in
            if user == nil {
                self.authenticateUserAndLoadHome()
            }
        }
        
        // Do any additional setup after loading the view.
        if ((GIDSignIn.sharedInstance.currentUser) != nil){
            setUpUserLabels()
            
        }
        
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
            //
        }
        authenticateUserAndLoadHome()
    }
    
    func setUpUserLabels() {
        nameLabel.text = Auth.auth().currentUser?.displayName;
        userEmailLabel.text = Auth.auth().currentUser?.email;
        let url = Auth.auth().currentUser?.photoURL?.absoluteString

        guard let imageUrl:URL = URL(string: url!) else {
                    return
                }

        guard let imageData = try? Data(contentsOf: imageUrl) else {return}
        let image = UIImage(data: imageData)
        userPhotoImageView.image=image
    }
}

