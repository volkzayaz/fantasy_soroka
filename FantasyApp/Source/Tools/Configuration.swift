//
//  Configuration.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Amplitude_iOS
import Parse
import Branch
import ZendeskSDK
import ZendeskCoreSDK
import ScreenShieldKit
import AppsFlyerLib
import Firebase
import FBSDKCoreKit

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
        
        let env = SettingsStore.environment.value
        
        // MARK: - Firebase
        FirebaseApp.configure()

        // MARK: - Parse
        Parse.initialize(with: ParseClientConfiguration { (config) in
            
            config.applicationId = env.parseApplicationId
            config.clientKey = env.parseClientKey
            
            config.server = ServerURL.parse
        })
        
        // MARK: - AppHud
        ApphudManager.configure()
        
        // MARK: - Branch
        // unncomment to disable debug mode
        //Branch.setUseTestBranchKey(true)
        
        let branch = Branch.getInstance()
        //branch?.setDebug()
        branch.registerFacebookDeepLinkingClass(AppLinkUtility.self)
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
          
            guard let identifier = params?["$canonical_identifier"] as? String else {
                return
            }
            
            if identifier.starts(with: "room/"),
               let accessToken = params?["inviteToken"] as? String {
            
                let roomId = String(identifier.dropFirst(5))
                Dispatcher.dispatch(action: ChangeInviteDeeplink(inviteDeeplink: .init(roomRef: .init(id: roomId), password: accessToken)))
                
            }
            
            if identifier.starts(with: "card/") {
                
                let parts = identifier.split(separator: "/")
                
                let cardID = parts[1]
                let senderID = parts[2] 
                
                Dispatcher.dispatch(action: OpenCard(cardId: String(cardID),
                                                     senderId: String(senderID)))
            }
            
            if identifier.starts(with: "collection/") {
                
                let collectionId = String(identifier.split(separator: "/")[1])
                
                Dispatcher.dispatch(action: OpenCollection(collectionId: collectionId))
                
            }
            
        })
        // uncomment to test Branch Integration
        //Branch.getInstance()?.validateSDKIntegration()

        if env == .dev {
            Parse.logLevel = .debug
        }

        Amplitude.instance()?.initializeApiKey(env.amplitudeKey)
        
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
    
    // MARK: - AppsFlyer
    static func startAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "2fKz2jDtEUvhuUW65J4Ewn"
        AppsFlyerLib.shared().appleAppID = "1230109516"
        AppsFlyerLib.shared().isDebug = !RunScheme.appstore
        
        NotificationCenter.default.addObserver(
            AppsFlyerLib.shared(),
            selector: #selector(AppsFlyerLib.start),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        AppsFlyerLib.shared().start()
    }
}

enum ServerURL {}
extension ServerURL {

    static let env = SettingsStore.environment.value.serverAlias
    
    static let base = "https://\(env).fantasyapp.com"
    
    static let parse = base + "/parseserver"
    static let api = base + "/api/v1"
    static let socket = base + "/socket.io/"
    
}
