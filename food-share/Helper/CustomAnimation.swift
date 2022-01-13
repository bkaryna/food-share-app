//
//  LoadingAnimation.swift
//  food-share
//
//  Created by Karyna Babenko on 23/12/2021.
//

import Foundation
import UIKit
import Lottie

class CustomAnimation {
    static func setUp(view: UIView, animationView: AnimationView, frequency: Float, type: String) {
        switch type{
        case "loading":
            animationView.animation = Animation.named("loading")
        case "done":
            animationView.animation = Animation.named("done")
        default:
            animationView.animation = Animation.named("loading")
        }
        
        switch view.traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    animationView.backgroundColor = .white
                case .dark:
                    animationView.backgroundColor = .black
        @unknown default:
            animationView.backgroundColor = .white
        }
        
        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .repeat(frequency)
        animationView.play()
        view.addSubview(animationView)
    }
}
