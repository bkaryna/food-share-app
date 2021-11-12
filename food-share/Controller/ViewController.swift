//
//  ViewController.swift
//  food-share
//
//  Created by Karyna Babenko on 25/10/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // TODO: hide navigation bar for this view only
        // self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //set up custom button style
        Styling.buttonStyle(signUpButton)
        Styling.buttonStyle(logInButton)

    }

    func transitionToHome() {
        let homeTabsViewController = storyboard?.instantiateViewController(identifier: "HomeTabsVC") as! UITabBarController
        super.view.window?.rootViewController = homeTabsViewController
        super.view.window?.makeKeyAndVisible()
    }

}

