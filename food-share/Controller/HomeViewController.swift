//
//  HomeViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 12/11/2021.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase

class HomeViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var addItemButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if ((Auth.auth().currentUser) != nil){
            setUpUserLabels()
        }
        Styling.buttonStyle(<#T##button: UIButton##UIButton#>)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { [self] auth, user in
            if user == nil {
                self.authenticateUserAndLoadHome()
            }
        }
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
            //
        }
        authenticateUserAndLoadHome()
    }
    
    func setUpUserLabels() {
        let userID = Auth.auth().currentUser?.uid
        
        let docRef = db.collection("Users").document(userID!)
        var name: String = ""
        var email: String = ""
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                name = document.get("Name") as! String
                email = document.get("Email") as! String
                
                self.nameLabel.text = name
                self.userEmailLabel.text = email
                
                print("Name: " + name)
                print("Email: " + email)
            } else {
                print("Document does not exist")
            }
        }

        
// for future custom photos
//        let url = Auth.auth().currentUser?.photoURL?.absoluteString
//
//        guard let imageUrl:URL = URL(string: url!) else {
//                    return
//                }
//
//        guard let imageData = try? Data(contentsOf: imageUrl) else {return}
//        let image = UIImage(data: imageData)
//        userPhotoImageView.image=image
    }
}

