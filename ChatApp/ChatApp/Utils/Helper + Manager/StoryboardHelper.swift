//
//  StoryboardHelper.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit

protocol StoryboardHelper {}

extension StoryboardHelper where Self: UIViewController {

    static func instantiate(storyboard: Storyboard) -> Self {
        let storyboard = UIStoryboard.storyboard(storyboard)
        return storyboard.instantiateViewController(ofType: Self.self)
    }

}

extension UIViewController: StoryboardHelper {}
