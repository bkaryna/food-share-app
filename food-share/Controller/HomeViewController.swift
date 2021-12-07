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
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if ((Auth.auth().currentUser) != nil){
            setUpUserLabels()
        }
        Styling.buttonStyle(addItemButton)
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
        setUpHomeNavigation()
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
                
                self.nameTextField.text = name
                self.emailTextField.text = email
                
                self.disableTextFieldEdit()
                
                print("Name: " + name)
                print("Email: " + email)
            } else {
                print("Document does not exist")
            }
        }
    }
        
    @objc func editUserProfile() {
        self.enableTextFieldEdit()
        setUpHomeEditNavigation()
    }
    
    func setUpHomeNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signOutAlert))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editUserProfile))
    }
    
    func setUpHomeEditNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelChanges))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveChanges))
    }
    
    @objc func cancelChanges() {
        setUpUserLabels()
        setUpHomeNavigation()
    }

    @objc func saveChanges() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = db.collection("Users").document(userID!)
        
        docRef.setData(["Name": nameTextField.text! as String, "Phone": phoneTextField.text! as String], merge: true)
        
        //work on empty strings
        informationAlert()
        setUpHomeNavigation()
        setUpUserLabels()
        
    }
    
    @objc func informationAlert() {
        let informationAlert = UIAlertController(title: "Edit profile", message: "Changes saved successfully", preferredStyle: .actionSheet)
        informationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(informationAlert, animated: true)
    }
    
    func enableTextFieldEdit() {
        self.nameTextField.isEnabled = true
        self.phoneTextField.isEnabled = true
        
        self.nameTextField.borderStyle = .roundedRect
        self.phoneTextField.borderStyle = .roundedRect
    }
    
    func disableTextFieldEdit() {
        self.nameTextField.isEnabled = false
        self.emailTextField.isEnabled = false
        self.phoneTextField.isEnabled = false
        
        self.nameTextField.borderStyle = .none
        self.phoneTextField.borderStyle = .none
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

