//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import UIKit
import FBSDKCoreKit
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shared = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupRoute()
        FirebaseApp.configure()
        KeyboardManager.setup()
        setupMainWindow()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    private func setupRoute() {
        AppUtils.setRootViewIsConversation()
    }
}

extension AppDelegate {
    
    private func setupMainWindow(windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        let navController = BaseNavigationController()
        let mainNavigator = MainNavigation(navigationController: navController)
        mainNavigator.navigate(to: .)
        window.rootViewController = navController
        return window
    }
}
