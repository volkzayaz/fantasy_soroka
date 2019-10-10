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
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return Branch.getInstance()?.application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        ) ?? true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Branch.getInstance()?.continue(userActivity)

        return true
    }
}
