//
//  Configuration.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

enum Configuration {}
extension Configuration {
    
    static func setUpServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    
        /**
         * Place to set up everything you would normally do in AppDelegate
         */
        
        Parse.initialize(with: ParseClientConfiguration { (config) in
            config.applicationId = "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
            config.clientKey = "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
            config.server = "https://api.fantasyapp.com/parseserver"
        })
        
        if Environment.debug {
            Parse.setLogLevel(.debug)
        }
        
        //Fabric.with([Crashlytics.self])
        
    }
    
}
