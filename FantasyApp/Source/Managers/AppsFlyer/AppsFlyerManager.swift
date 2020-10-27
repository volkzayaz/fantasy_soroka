//
//  AppsFlyerManager.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 24.10.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import AppsFlyerLib

final class AppsFlyerManager {
    
    static var isAvailable: Bool {
        immutableNonPersistentState?.isAppsFlyerEnabled == true
    }
    
    static func configure() {
        guard isAvailable else {
            return
        }
        
        AppsFlyerLib.shared().appsFlyerDevKey = "2fKz2jDtEUvhuUW65J4Ewn"
        AppsFlyerLib.shared().appleAppID = "1230109516"
        AppsFlyerLib.shared().isDebug = !RunScheme.appstore
        
        AppsFlyerLib.shared().start()
    }
    
    static func handlePush(with notification: UNNotification) {
        if isAvailable {
            AppsFlyerLib.shared().handlePushNotification(notification.request.content.userInfo)
        }
    }
    
    static func handleOpen(_ url: URL?, options: [AnyHashable : Any]?) {
        if isAvailable {
            AppsFlyerLib.shared().handleOpen(url, options: options)
        }
    }
    
    static func logEvent(_ name: String, withValues values: [AnyHashable : Any]?) {
        if isAvailable {
            AppsFlyerLib.shared().logEvent(name, withValues: values)
        }
    }
}
