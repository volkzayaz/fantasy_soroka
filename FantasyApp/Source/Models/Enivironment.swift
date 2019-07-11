//
//  Enivironment.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum Environment {}
extension Environment {
    
    static var debug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var adhoc: Bool {
        #if ADHOC
        return false
        #else
        return true
        #endif
    }
    
    static var appstore: Bool {
        #if DEBUG || ADHOC
        return false
        #else
        return true
        #endif
    }
    
}
