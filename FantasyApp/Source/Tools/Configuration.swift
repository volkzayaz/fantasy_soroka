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
import ZendeskSDK
import ZendeskCoreSDK
import ScreenShieldKit

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
            
//            if Environment.debug {
//                config.applicationId = "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
//                config.clientKey = "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
//            }
//            else {
                config.applicationId = "527a9cf3a253b72a312835f0e4c1d20d23c22eb5"
                config.clientKey = "6886ac343b6f721db688a259d0ee51d84ea2fbe4"
            //}
            
            config.server = ServerURL.parse
        })

        // MARK: - Facebook
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        // MARK: - Branch
        // unncomment to disable debug mode
        //Branch.setUseTestBranchKey(true)
        
        let branch = Branch.getInstance()
        //branch?.setDebug()
        branch?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
          
            guard let identifier = params?["$canonical_identifier"] as? String,
                identifier.starts(with: "room/"),
                let accessToken = params?["inviteToken"] as? String else {
                return
            }
            
            let roomId = String(identifier.dropFirst(5))
            Dispatcher.dispatch(action: ChangeInviteDeeplink(inviteDeeplink: .init(roomRef: .init(id: roomId), password: accessToken)))
            
        })
        // uncomment to test Branch Integration
        //Branch.getInstance()?.validateSDKIntegration()

        // MARK: - Logging
        if Environment.debug {
            Parse.logLevel = .debug
        }

        // MARK: - Analytics (Amplitude)
        let key: String
        if Environment.appstore {
            key = "be790981c8f961486368e7af48ffa984"
        }
        else if Environment.adhoc {
            key = "be790981c8f961486368e7af48ffa984"
        }
        else {
            key = "43d33719cb8721c70c1935aaeb791d1d"
        }
        
        Amplitude.instance()?.initializeApiKey(key)
        
        ///in case AppState initialisation becomes async
        ///we need to delay app ViewControllers presentation
        let _ = Dispatcher.kickOff().subscribe()
        
        ///StoreKit complete transactions
        PurchaseManager.completeTransacions()
        
        ///Push registration
        PushManager.kickOff()


        /// Zendesk
        Zendesk.initialize(appId: "9d8b51fca51b5f85a64615805f9db77a547e239d9f7aa0b4",
            clientId: "mobile_sdk_client_38524f5c375d9e45cf0f",
            zendeskUrl: "https://fantasyapp.zendesk.com")
        Theme.currentTheme.primaryColor = UIColor.fantasyPink

        Support.initialize(withZendesk: Zendesk.instance)

        let ident = Identity.createAnonymous()
        Zendesk.instance?.setIdentity(ident)
        
        ScreenShieldKit.setLicenseKey("MEYCIQCmVNd4n8TuyWQOio/fbUzxcve7s0r1CPL1lqL6lVhrygIhAJ0QNGAx55BQ/LZYfCLa5aSnVQykAaFKigYiteMlMvsb")
    }

    private static func registerActors() {
        let actors: [Any] = [
            UserPropertyActor(),
        ]
        actors.forEach { ActorLocator.shared.register($0) }
    }

}

enum ServerURL {}
extension ServerURL {

//    #if DEBUG
    //static let env = "dev"
//    #else
    static let env = "prod"
    //#endif
    
    static let base = "https://\(env).fantasyapp.com"
    
    static let parse = base + "/parseserver"
    static let api = base + "/api/v1"
    static let socket = base + "/socket.io/"
    
}
