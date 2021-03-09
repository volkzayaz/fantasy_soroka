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
//import ScreenShieldKit
import Firebase
import FBSDKCoreKit
import Segment
import AppTrackingTransparency
import AdSupport
import Sentry

enum Configuration {}
extension Configuration {

    static func setup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        setupServices(launchOptions: launchOptions)
        registerActors()
    }
    
    static func setUpSegment() {
        guard immutableNonPersistentState?.isSegmentEnabled == true else {
            return
        }
        
        let configuration = AnalyticsConfiguration(writeKey: SettingsStore.environment.value.segmentWriteKey)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        configuration.trackPushNotifications = true
        configuration.trackDeepLinks = true
        configuration.enableAdvertisingTracking = true
        configuration.adSupportBlock = {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        
        Segment.Analytics.setup(with: configuration)
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
        
        SentrySDK.start { options in
            options.dsn = "https://5131770ed33b4386948f1bcd77f30c2d@o509005.ingest.sentry.io/5602579"
//            options.debug = true
        }
        
//        ScreenShieldKit.setLicenseKey("MEYCIQCmVNd4n8TuyWQOio/fbUzxcve7s0r1CPL1lqL6lVhrygIhAJ0QNGAx55BQ/LZYfCLa5aSnVQykAaFKigYiteMlMvsb")
        
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
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

    static let env = SettingsStore.environment.value.serverAlias
    
    static let base = "https://\(env).fantasyapp.com"
    
    static let parse = base + "/parseserver"
    static let api = base + "/api/v1"
    static let socket = base + "/socket.io/"
    
}
