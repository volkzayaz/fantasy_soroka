//
//  AppDelegate.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Branch
import ZendeskSDK
import ZendeskCoreSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Configuration.setup(launchOptions: launchOptions)

        Zendesk.initialize(appId: "9d8b51fca51b5f85a64615805f9db77a547e239d9f7aa0b4",
            clientId: "mobile_sdk_client_38524f5c375d9e45cf0f",
            zendeskUrl: "https://fantasyapp.zendesk.com")
        Theme.currentTheme.primaryColor = UIColor.fantasyPink
        
        Support.initialize(withZendesk: Zendesk.instance)

        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance()?.application(app, open: url, options: options)
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

}

