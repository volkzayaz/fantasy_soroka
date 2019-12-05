//
//  TimeSpentCounter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

typealias TimeSpent = Int ///seconds
struct TimeSpentCounter {
    
    private var startDate: Date?
    
    mutating func start() {
        startDate = Date()
    }
    
    mutating func finish() -> TimeSpent {
        guard let x = startDate else {
            fatalErrorInDebug("Can't finish counter before calling |start|")
            return 0
        }
        startDate = nil
        
        return Int( Date().timeIntervalSince(x) )
    }
    
}
