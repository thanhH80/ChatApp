//
//  CustomNavigation.swift
//  RealTimeChat
//
//  Created by Jack Lewis on 30/05/2023.
//

import UIKit

typealias GradientPoint = (x: CGPoint, y: CGPoint)

enum GradientDirection: Int {
    case leftToRight = 0
    case rightToLeft = 1
    case topToBottom = 2
    case bottomToTop = 3
    case topLeftToBottomRight = 4
    case bottomRightToTopLeft = 5
    case topRightToBottomLeft = 6
    case bottomLeftToTopRight = 7
    
    var value: Int { return rawValue }
    
    func draw() -> GradientPoint {
        switch self {
        case .leftToRight:
            return (x: CGPoint(x: 0, y: 0.5), y: CGPoint(x: 1, y: 0.5))
        case .rightToLeft:
            return (x: CGPoint(x: 1, y: 0.5), y: CGPoint(x: 0, y: 0.5))
        case .topToBottom:
            return (x: CGPoint(x: 0.5, y: 0), y: CGPoint(x: 0.5, y: 1))
        case .bottomToTop:
            return (x: CGPoint(x: 0.5, y: 1), y: CGPoint(x: 0.5, y: 0))
        case .topLeftToBottomRight:
            return (x: CGPoint(x: 0, y: 0), y: CGPoint(x: 1, y: 1))
        case .bottomRightToTopLeft:
            return (x: CGPoint(x: 1, y: 1), y: CGPoint(x: 0, y: 0))
        case .topRightToBottomLeft:
            return (x: CGPoint(x: 1, y: 0), y: CGPoint(x: 0, y: 1))
        case .bottomLeftToTopRight:
            return (x: CGPoint(x: 0, y: 1), y: CGPoint(x: 1, y: 0))
        }
    }
}

protocol CustomNavigation { }

// MARK: - Title View
extension CustomNavigation where Self: UIViewController {
    
    func customNavigationTitleView(title: String) {
//        let titleLabel = UILabel()
//        titleLabel.text                 = title
//        titleLabel.textColor            = .blue6A9CFD
//        titleLabel.numberOfLines        = 0
//        titleLabel.font                 = UIFont.systemFont(ofSize: 20, weight: .bold)
//        titleLabel.textAlignment        = .center
//        navigationItem.titleView        = titleLabel
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .blueAEE4FF.withAlphaComponent(0.8)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
}

// MARK: - Background
enum BackgroundStyle {
    case gradient
    case clear
}

extension CustomNavigation where Self: UIViewController {
    
    func customNavigationBackgroundColor(_ color: UIColor, isHideBorderShadow: Bool = true) {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        let isHideShadow = color == .clear || isHideBorderShadow
        navigationController?.navigationBar.setValue(isHideShadow, forKey: "hidesShadow")
    }

    func setNavigationGradientBackground(gradientDirection: GradientDirection) {
        if let navigationBar = navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            bounds.size.height += statusBarHeight
            gradient.frame = bounds
            gradient.colors = [UIColor.blue.cgColor, UIColor.blue.cgColor]
            gradient.startPoint = gradientDirection.draw().x
            gradient.endPoint = gradientDirection.draw().y
            
            if let image = getImageFrom(gradientLayer: gradient) {
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
            }
        }
    }
    
    private func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
            //gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
}

// MARK: - Back Button
extension CustomNavigation where Self: UIViewController{
    
    func setNavigationBackBarButtonEmptyTitle() {
        let backBarItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarItem
    }
    
    func setNavigationItemsColor(color: UIColor) {
        navigationController?.navigationBar.tintColor = color
    }
    
}

