//
//  AppDelegate.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
//        STPPaymentConfiguration.shared().publishableKey = Constants.publishableKey

        if let systemVersion = Double(UIDevice.current.systemVersion) {
            if systemVersion < 13.0 {
                let mainController = MainController(collectionViewLayout: UICollectionViewFlowLayout())
                let navVC = UINavigationController(rootViewController: mainController)
                navVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navVC.navigationBar.shadowImage = UIImage()
                navVC.navigationBar.isTranslucent = true
                navVC.view.backgroundColor = UIColor.clear
                window?.rootViewController = navVC
            }
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let isDynamicLink = DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url)
        if isDynamicLink {
          let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
          return handleDynamicLink(dynamicLink)
        }
        // Handle incoming URL with other methods as necessary
        // ...
        return false
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let dynamicLinks = DynamicLinks.dynamicLinks()
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
            if (dynamicLink != nil) && !(error != nil) {
                let handleDynamicLink = self.handleDynamicLink(dynamicLink)
                print(handleDynamicLink)
            }
        }
        if !handled {
          // Handle incoming URL with other methods as necessary
          // ...
        }
        return handled
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink else { return false }
        guard let deepLink = dynamicLink.url else { return false }
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let invitedBy = queryItems?.filter({(item) in item.name == "invitedby"}).first?.value
        let user = Auth.auth().currentUser
        // If the user isn't signed in and the app was opened via an invitation
        // link, sign in the user anonymously and record the referrer UID in the
        // user's RTDB record.
        if user == nil && invitedBy != nil {
            Auth.auth().signInAnonymously() { (user, error) in
                if let user = user {
                    let userRecord = Database.database().reference().child("users").child(user.user.uid)
                    userRecord.child("referred_by").setValue(invitedBy)
                    let discountCode = self.generateDiscountCode()
                    let discountRecord = Database.database().reference().child("discounts").child("\(invitedBy ?? "")").child(discountCode)
                    discountRecord.setValue(discountCode)
                    if dynamicLink.matchType == .weak {
                      // If the Dynamic Link has a weak match confidence, it is possible
                      // that the current device isn't the same device on which the invitation
                      // link was originally opened. The way you handle this situation
                      // depends on your app, but in general, you should avoid exposing
                      // personal information, such as the referrer's email address, to
                      // the user.
                        
                    }
                }
            }
        }
        return true
    }
    
    func generateDiscountCode() -> String {
        let base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var discountCode: String = ""

        for _ in 0..<8 {
            let randomValue = arc4random_uniform(UInt32(base.count))
            discountCode += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return discountCode
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

