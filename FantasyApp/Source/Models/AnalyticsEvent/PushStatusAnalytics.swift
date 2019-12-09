//
//  PushStatusAnalytics.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 08.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics {
    enum PushStatus: String {
        
        case quiet
        case prominent
        case provisional
        case turnedOff
        
        init(settings: UNNotificationSettings) {
            
            if case .denied = settings.authorizationStatus {
                self = .turnedOff
                return
            }
            
            if case .provisional = settings.authorizationStatus {
                self = .provisional
                return
            }
            
            if settings.lockScreenSetting == .enabled ||
               settings.alertStyle != .none ||
               settings.soundSetting == .enabled {
                self = .prominent
                return
            }
               
            self = .quiet
            
        }
        
    }
}
