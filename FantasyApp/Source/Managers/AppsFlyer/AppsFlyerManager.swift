//
//  AppsFlyerManager.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 24.10.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import AppsFlyerLib
import ApphudSDK

final class AppsFlyerManager: NSObject {
    
    static let shared: AppsFlyerManager = AppsFlyerManager()
    
    static var isAvailable: Bool {
        immutableNonPersistentState?.isAppsFlyerEnabled == true
    }
    
    static func configure() {
        guard isAvailable else {
            return
        }
        
        AppsFlyerLib.shared().appsFlyerDevKey = SettingsStore.environment.value.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = SettingsStore.environment.value.appsFlyerAppleAppID
        AppsFlyerLib.shared().isDebug = !RunScheme.appstore
        AppsFlyerLib.shared().delegate = shared
        
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

extension AppsFlyerManager: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        Apphud.addAttribution(data: conversionInfo, from: .appsFlyer, identifer: AppsFlyerLib.shared().getAppsFlyerUID()) { _ in }
    }

    func onConversionDataFail(_ error: Error) {
        Apphud.addAttribution(data: ["error" : error.localizedDescription], from: .appsFlyer, identifer: AppsFlyerLib.shared().getAppsFlyerUID()) { _ in }
    }
}
