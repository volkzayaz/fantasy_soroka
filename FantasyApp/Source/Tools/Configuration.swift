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
import Amplitude_iOS
import Parse
import Branch

enum Configuration {}
extension Configuration {

    static func setup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        setupServices(launchOptions: launchOptions)
        registerActors()
    }
    
    private static func setupServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    
        /**
         * Place to set up everything you would normally do in AppDelegate
         */

        // MARK: - Fabric
        Fabric.with([Crashlytics.self])

        // MARK: - Parse
        Parse.initialize(with: ParseClientConfiguration { (config) in
//            config.applicationId = "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
//            config.clientKey = "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
//            config.server = "https://api.fantasyapp.com/parseserver"
            
            config.applicationId = "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
            config.clientKey = "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
            config.server = "https://apidev.fantasyapp.com/parseserver"
        })

        // MARK: - Facebook
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        //FBSDKSettings.setAppID("1298342663520828") 
        //PFFacebookUtils.facebookLoginManager().loginBehavior = .browser

        // MARK: - Branch
        // unncomment to disable debug mode
        Branch.setUseTestBranchKey(true)
        let branch = Branch.getInstance()
        branch?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            
         })

        // MARK: - Logging
        if Environment.debug {
            Parse.setLogLevel(.debug)
        }

        // MARK: - Analytics (Amplitude)
        Amplitude.instance()?.initializeApiKey("8ef1a93282a6ca16bfe1341dedd639dc")
        
        ///in case AppState initialisation becomes async
        ///we need to delay app ViewControllers presentation
        let _ = Dispatcher.kickOff().subscribe()
        
        ///StoreKit complete transactions
        PurchaseManager.completeTransacions()
        
        ///Push registration
        PushManager.kickOff()

        // uncomment to test Branch Integration
        // Branch.getInstance()?.validateSDKIntegration()
    }

    private static func registerActors() {
        let actors: [Any] = [
            UserPropertyActor(),
            RoomsActor()
        ]
        actors.forEach { ActorLocator.shared.register($0) }
    }
    
}
