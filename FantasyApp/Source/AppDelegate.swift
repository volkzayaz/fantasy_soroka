//
//  AppDelegate.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Branch

import FBSDKLoginKit
import FBSDKCoreKit

import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let appLaunchedKey = "app_launched_at_least_once"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { _, _ in
            return true
        }
        
        Configuration.setup(launchOptions: launchOptions)
        
        application.applicationSupportsShakeToEdit = true
        
        if Bool(self.appLaunchedKey) == nil {
            Analytics.setUserProps(props: ["Profile Status: Type": "Incomplete Sign-Up"])
            true.store(for: self.appLaunchedKey)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        
        ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushManager.updateDeviceToken(data: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        RemoteConfigManager.fetch()
    }
}

