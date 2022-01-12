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
import FirebaseStorage
import Photos
import Lottie

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var myItemsButton: UIButton!
    
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private var image: UIImage = UIImage()
    private var imageData: Data = Data()
    
    let animationView = AnimationView()
    
    override func viewWillAppear(_ animated: Bool) {
        if ((Auth.auth().currentUser) != nil){
            setUpUserLabels()
        }
        disableEdit()
        Styling.buttonStyle(addItemButton)
        Styling.buttonStyle(myItemsButton)
        Styling.makeImageCornersRound(userPhotoImageView)

        
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
        setUpUserLabels()
        
        CustomAnimation.setUp(view: view, animationView: animationView, frequency: 3, type: "loading")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.animationView.stop()
            self.animationView.isHidden = true
        }
        
        //set up navigation bar
        setUpHomeNavigation()
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.userPhotoImageView.image = image
            }
        }
        task.resume()
        UserItems.getUserItemsList()
        OtherItems.getOtherItemsList()
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
        var phone: String = ""
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                name = document.get("Name") as! String
                email = document.get("Email") as! String
                phone = document.get("Phone") as! String
                
                self.nameTextField.text = name
                self.emailTextField.text = email
                self.phoneTextField.text = phone
                
                self.disableEdit()
                
            } else {
                print("Document does not exist")
            }
        }
        
        let ref = storage.child("\(userID!)/images/profile/photo.png")
        ref.downloadURL { url, error in
            if (error != nil) {
                self.userPhotoImageView.image = UIImage(named: "user-avatar")
                return
            } else {
                // Get the download URL for 'images/stars.jpg'
                try? self.userPhotoImageView.image = UIImage(data: Data(contentsOf: url!))
                print("\(String(describing: url?.absoluteString))")
            }
        }
        
    }
    
    @objc func editUserProfile() {
        self.enableEdit()
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
        
        let ref = storage.child("\(userID!)/images/profile/photo.png")
        ref.putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                return
            }
            
            ref.downloadURL (completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                //for future reference
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
                
            })
        })
        
        //work on empty strings
        informationAlert(title: "Edit profile", message: "Changes saved successfully")
        setUpHomeNavigation()
        disableEdit()
        
    }
    
    @objc func informationAlert(title: String, message: String) {
        let informationAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        informationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(informationAlert, animated: true)
    }
    
    func enableEdit() {
        self.nameTextField.isEnabled = true
        self.phoneTextField.isEnabled = true
        
        self.nameTextField.borderStyle = .roundedRect
        self.phoneTextField.borderStyle = .roundedRect
        
        self.editPhotoButton.isHidden = false
    }
    
    func disableEdit() {
        self.nameTextField.isEnabled = false
        self.emailTextField.isEnabled = false
        self.phoneTextField.isEnabled = false
        
        self.nameTextField.borderStyle = .none
        self.phoneTextField.borderStyle = .none
        
        self.editPhotoButton.isHidden = true
    }
    
    @IBAction func editPhotoButtonTapped(_ sender: Any) {
        var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let picker = UIImagePickerController()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) {
                    newStatus in
                    switch newStatus
                    {case .restricted:
                        // The system restricted this app's access.
                        DispatchQueue.main.async {
                        picker.sourceType = .photoLibrary
                        picker.delegate = self
                        picker.allowsEditing = true
                        self.present(picker, animated: true)
                        }
                    case .denied:
                        DispatchQueue.main.async {
                            readWriteStatus = .notDetermined
                            self.informationAlert(title: "Access denied", message: "Please allow access to photo library.")
                        }
                    case .authorized:
                        DispatchQueue.main.async {
                        picker.sourceType = .photoLibrary
                        picker.delegate = self
                        picker.allowsEditing = true
                        self.present(picker, animated: true)
                        }
                    case .limited:
                        DispatchQueue.main.async {
                        picker.sourceType = .photoLibrary
                        picker.delegate = self
                        picker.allowsEditing = true
                        self.present(picker, animated: true)
                        }
                    @unknown default:
                        fatalError()
                    }}
            case .restricted:
                // The system restricted this app's access.
                DispatchQueue.main.async {
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true)
                }
            case .denied:
                DispatchQueue.main.async {
                    readWriteStatus = .notDetermined
                    self.informationAlert(title: "Access denied", message: "Please allow access to photo library.")
                }
            case .authorized:
                DispatchQueue.main.async {
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true)
                }
            case .limited:
                DispatchQueue.main.async {
                    picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true)
                }
            @unknown default:
                fatalError()
            }
        }
        
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.delegate = self
//        picker.allowsEditing = true
//        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!
        imageData = image.pngData()!
        userPhotoImageView.image = UIImage(data: imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
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

