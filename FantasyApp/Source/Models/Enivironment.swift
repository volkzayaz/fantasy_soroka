//
//  Enivironment.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum Environment: String, CaseIterable, UserDefaultsStorable {
    case dev, staging, production
    
    static var `default`: Environment {
        
        if RunScheme.appstore {
            return .production
        } else {
            return .dev
        }
        
    }
}

extension Environment {
    
    var parseClientKey: String {
        switch self {
            
        case .dev       : return "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
        case .staging   : return "8c48e9b378ba8a6f1616ff78c3536c9f35437225"
        case .production: return "6886ac343b6f721db688a259d0ee51d84ea2fbe4"
            
        }
    }
    
    var parseApplicationId: String {
        switch self {
            
        case .dev       : return "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
        case .staging   : return "416c8bf3a253b72a312835f0e4c1d20d23c22eb5"
        case .production: return "527a9cf3a253b72a312835f0e4c1d20d23c22eb5"
            
        }
    }
    
    var amplitudeKey: String {
        switch self {
            
        case .dev       : return "43d33719cb8721c70c1935aaeb791d1d"
        case .staging   : return "8ce166f7a21add33a5f1cb1de1bb2fca"
        case .production: return "be790981c8f961486368e7af48ffa984"
            
        }
    }
    
    var serverAlias: String {
        switch self {
            
        case .dev       : return "dev"
        case .staging   : return "stg"
        case .production: return "prod"
            
        }
    }
    
}

enum RunScheme {
}; extension RunScheme {
    
    static var debug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var adhoc: Bool {
        #if ADHOC
        return true
        #else
        return false
        #endif
    }
    
    static var appstore: Bool {
        #if DEBUG || ADHOC
        return true
        #else
        return false
        #endif
    }
    
}
