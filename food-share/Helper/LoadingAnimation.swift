//
//  LoadingAnimation.swift
//  food-share
//
//  Created by Karyna Babenko on 23/12/2021.
//

import Foundation
import UIKit
import Lottie

class LoadingAnimation {
    static func setUp(view: UIView, animationView: AnimationView, frequency: Float) {
        //animationView.animation = Animation.named("")
        animationView.animation = Animation.named("loading")
        
        switch view.traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    animationView.backgroundColor = .white
                case .dark:
                    animationView.backgroundColor = .black
        @unknown default:
            animationView.animation = Animation.named("loading")
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
