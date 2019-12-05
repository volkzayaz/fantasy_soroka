//
//  AnalyticsEvent.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

protocol AnalyticsEvent {
    var name: String { get }
    var props: [String: String]? { get }
}

extension AnalyticsEvent {
    var props: [String: String]? { return nil }
}

extension Analytics {
    enum Event {}
}

extension Analytics.Event {
    
    struct LocationPermissionChange: AnalyticsEvent {
        
        let authStatus: CLAuthorizationStatus
        
        private var value: Value {
            switch authStatus {
            case .notDetermined, .denied, .restricted: return .NotAllowed
            case .authorizedWhenInUse, .authorizedAlways: return .WhileUsing
            }
        }
        
        enum Value: String {
            case NotAllowed, WhileUsing, AllowOnce
        }
        
        var name: String {
            
            switch value {
            case .AllowOnce, .WhileUsing:
                return "Location"
            
            case .NotAllowed:
                return "Location Failed"
                
            }
            
        }
        
        var props: [String : String]? {
            return ["Location": value.rawValue]
        }
    }
    
    struct ProfileDelete: AnalyticsEvent {
        var name: String { return "Profile Delete" }
    }
    
    struct ProfileLogout: AnalyticsEvent {
        var name: String { return "Profile Logout" }
    }
    
}
