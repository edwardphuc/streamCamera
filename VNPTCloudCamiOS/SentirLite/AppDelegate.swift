//
//  AppDelegate.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/24/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import Crashlytics
import Fabric
import Alamofire
import SCLAlertView
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var logginUser: User?
    var restrictRotation: Bool = false
    var connectionManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    var alertView:SCLAlertView?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        connectionManager?.listener = { status in
            
            switch status {
            case .notReachable:
                
                NotificationCenter.default.post(name: kReceiveDisconnectionStatus, object: nil)
                
            case .reachable(_):
                
                NotificationCenter.default.post(name: kReceiveHasConnectionStatus, object: nil)
                
            default:
                
                print(status)
                
            }
        }
        
        if let domain = UserDefaults.standard.string(forKey: "Domain") {
            URLs.domain = domain
        } else {
            URLs.domain = URLs.server1
        }
        
        
        connectionManager?.startListening()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert, .sound ], categories: nil))
        application.registerForRemoteNotifications()

        Fabric.with([Crashlytics.self])
        logUser()
        // Override point for customization after application launch.
        return true
    }
    func showDisconnectDialog() {
        
        if UIApplication.shared.keyWindow == nil { return }
        
        if alertView != nil { return }
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false
            
        )
        
        alertView = SCLAlertView(appearance: appearance)
        alertView?.addButton("OK", backgroundColor: COLOR.mainBlueColor) {
            
        }
        
       
        alertView?.showError("Conection", subTitle:  NSLocalizedString("network_conection", comment: ""), animationStyle: .topToBottom)
        
        
    }
    func dismissDisconnectDialog() {
        alertView?.dismiss(animated: true, completion: {
            
            self.alertView = nil
        })
        
    }

    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Test User")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: kRefreshData, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if restrictRotation {
            return .portrait
        }
        else {
            return .all
        }
    }


}

