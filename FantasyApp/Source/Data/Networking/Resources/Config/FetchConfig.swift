//
//  FetchConfig.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 29.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct ServerConfig: Codable {
    
    let subscriptionProductIDs: Set<String>?
    let minSupportedIOSVersion: CodableVersion
    let screenProtectEnabled: Bool
    let fantasyCardsShare: ShareLinks
    let termsAndConditions: Legal
    let isAppsFlyerEnabled: Bool
    let isSegmentEnabled: Bool
    
    struct ShareLinks: Codable {
        let card: String
        let collection: String
    }
    
    struct Legal: Codable {
        let title: String
        let body: String
    }
}

struct CodableVersion: Codable {
    
    let version: String
    
    init(from decoder: Decoder) throws {
        version = try (try decoder.singleValueContainer()).decode(String.self)
    }

    var cocoaVersion: CocoaVersion {
        return CocoaVersion(string: version)
    }
    
}

struct CocoaVersion : CustomStringConvertible {
    
    static var current: CocoaVersion {
        let str = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        return .init(string: str)
    }

    
    let currentVersion = "3.0.1"
    let storeVersion = "3.0.2"
    
    static func < (left: CocoaVersion, right: CocoaVersion) -> Bool {
        return right.description.compare(left.description, options: .numeric) == .orderedDescending
    }
    
    var major: Int
    var minor: Int
    var patch: Int
    
    init() {
        major = 0
        minor = 1
        patch = 0
    }
    
    init(string: String) {
        let comps = string.components(separatedBy: ".")
        guard comps.count == 3,
              let maj = Int(comps[0]),
              let min = Int(comps[1]),
              let pat = Int(comps[2]) else {
            fatalError("Invalid cocoa version string \(string)")
        }

        major = maj
        minor = min
        patch = pat
        
    }
    
    enum BumpType: String {
        case patch, minor, major
    };
    
    mutating func bumpUp(type: BumpType) {
        
        switch type {
        case .patch:
            patch+=1
            
        case .minor:
            patch = 0
            minor+=1
            
        case .major:
            patch = 0
            minor = 0
            major+=1
        
        }
        
    }
    
    var description: String {
        return "\(major).\(minor).\(patch)"
    }
    
}


struct FetchConfig: APIResource {
    
    var path: String {
        return "/global-settings"
    }
    
    var method: Moya.Method {
        return .get
    }
        
    typealias responseType = ServerConfig
    
    var task: Task {
        return .requestPlain
    }
    
}
