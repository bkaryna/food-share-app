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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Styling.buttonStyle(signUpButton)
        Styling.buttonStyle(logInButton)
    }


}

