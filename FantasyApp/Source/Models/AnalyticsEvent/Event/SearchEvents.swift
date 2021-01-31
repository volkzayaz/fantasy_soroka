//
//  SearchEvents.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 30.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    enum Community {
        case activeCity(String)
        case none
        
        var value: String {
            switch self {
            case .activeCity(let city):
                return city
            case .none:
                return "None"
            }
        }
    }
    
    struct ProfilePreview: AnalyticsEvent {
        
        let name = "Profile Preview"
        let isViewedBefore: Bool
        
        var props: [String: String]? {
            [
                "Viewed Before": isViewedBefore ? "true" : "false"
            ]
        }
    }
    
    struct SearchNonActiveCity: AnalyticsEvent {
        
        let name = "Search NonActiveCity"
        let location: String?
        
        var props: [String: String]? {
            [
                "Location": location ?? "Your city"
            ]
        }
    }
    
    struct SearchNoNewUsers: AnalyticsEvent {
        
        let name = "Search NoNewUsers"
//        let currentCity: Community
//        let location: String
        let searchPreferences: SearchPreferences?
        let membership: Bool
        
        var props: [String: String]? {
            var result = [
//                "CurrentCity": currentCity.value,
//                "Location": location,
                "Membership": membership ? "true" : "false"
            ]
            
            if let searchPreferences = searchPreferences {
                result["Sex"] = searchPreferences.gender.pretty
                result["Age"] = "\(searchPreferences.age.lowerBound) - \(searchPreferences.age.upperBound)"
                result["Global Mode"] = (searchPreferences.isGlobalMode == true) ? "on" : "off"
            }
            
            return result
        }
    }
    
    struct FlirtOptions: AnalyticsEvent {
        
        let name = "Search NoNewUsers"
//        let currentCity: Community
//        let location: String
        let searchPreferences: SearchPreferences?
        let membership: Bool
        
        var props: [String: String]? {
            var result = [
//                "CurrentCity": currentCity.value,
//                "Location": location,
                "Membership": membership ? "true" : "false"
            ]
            
            if let searchPreferences = searchPreferences {
                result["Sex"] = searchPreferences.gender.pretty
                result["Age"] = "\(searchPreferences.age.lowerBound) - \(searchPreferences.age.upperBound)"
                result["Global Mode"] = (searchPreferences.isGlobalMode == true) ? "on" : "off"
            }
            
            return result
        }
    }
}
