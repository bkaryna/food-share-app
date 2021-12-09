//
//  Style.swift
//  food-share
//
//  Created by Karyna Babenko on 30/10/2021.
//

import Foundation
import UIKit

class Styling {
    static func buttonStyle (_ button: UIButton) {
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    static func makeImageCornersRound(_ image: UIImageView) {
        image.layer.cornerRadius = 125
        image.clipsToBounds = true
    }
}
