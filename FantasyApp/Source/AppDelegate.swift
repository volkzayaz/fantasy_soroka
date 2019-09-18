//
//  AppDelegate.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Configuration.setup(launchOptions: launchOptions)
                
//        CLGeocoder().rx.cities(near: CLLocation(latitude: 42.645815, longitude: 18.0590278))
//            .subscribe()
        
        return true
    }

}
