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

import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Configuration.setup(launchOptions: launchOptions)
        
        application.applicationSupportsShakeToEdit = true
        
        if SettingsStore.isAppsFlyerEnabled.value {
            AppsFlyerTracker.shared().appsFlyerDevKey = "2fKz2jDtEUvhuUW65J4Ewn"
            AppsFlyerTracker.shared().appleAppID = "1230109516"
            AppsFlyerTracker.shared().delegate = self
            
            #if DEBUG || ADHOC
            AppsFlyerTracker.shared().isDebug = true
            #endif
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sendLaunch),
                name: UIApplication.didBecomeActiveNotification,
                object: nil)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance()?.application(app, open: url, options: options)
        
        ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance()?.continue(userActivity)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushManager.updateDeviceToken(data: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }

}

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
    
    @objc func sendLaunch(app: Any) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}
