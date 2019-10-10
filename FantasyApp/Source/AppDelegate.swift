//
//  AppDelegate.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Configuration.setup(launchOptions: launchOptions)
        
        return true
    }

    // MARK: - deep linking
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      Branch.getInstance()?.application(app, open: url, options: options)
      return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      Branch.getInstance()?.continue(userActivity)
      return true
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      Branch.getInstance()?.handlePushNotification(userInfo)
    }
}
