//
//  Navigator.swift
//  ChatApp
//
//  Created by Thagion Jack on 26/07/2023.
//

import Foundation

protocol Navigator {
    associatedtype Destination
    
    func navigate(to destination: Destination)
}
