//
//  ServerBusinessLogic.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/12/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum ServerBusinessLogic {}
extension ServerBusinessLogic {
    
    private(set) static var swipeState: ServerBusinessLogic.SwipeState? = nil
    
    static func logout() {
        swipeState = nil
    }
    
}

/**
 SwipeState for UserSearch. All this code should really live on server. Drop it once we migrate to outr own backend
 */

extension ServerBusinessLogic {
    
    private static let swipesPerDay = 20 ///TODO: fetch from PFConfig
    
    class SwipeState: ParsePresentable {
        
        static var className: String {
            return "DiscoverySwipeState"
        }
        
        var objectId: String?
        var userId: String?
        var swipesLeft: Int?
        var batchGranted: Date?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(userId, forKey: .userId)
            try container.encode(swipesLeft, forKey: .swipesLeft)
            try container.encode(batchGranted, forKey: .batchGranted)
            
        }
        
        init() {
            userId = User.current!.id
        }
        
    }
    
    static func convertToNative(serverState: ServerBusinessLogic.SwipeState) -> DiscoverProfileViewModel.SwipeState {
        
        var newState = serverState
        defer {
            self.swipeState = newState
        }
        
        let now = Date()
        let dayInSeconds: TimeInterval = 24 * 3600
        
        guard let granted = serverState.batchGranted else {
            ///Brand new serverState. Granting 20 swipes now
            newState.batchGranted = now
            return .limit(ServerBusinessLogic.swipesPerDay)
        }
        
        if now.timeIntervalSince(granted) > dayInSeconds {
            ///24 hours passed, reseting the timer
            newState.batchGranted = now
            return .limit(ServerBusinessLogic.swipesPerDay)
        }
        
        if let x = newState.swipesLeft {
            return .limit(x)
        }
        
        return .tillDate(granted.addingTimeInterval(dayInSeconds))
        
    }
    
    static func applyNative(swipeState: DiscoverProfileViewModel.SwipeState) -> ServerBusinessLogic.SwipeState {
        
        guard let state = self.swipeState else {
            fatalError("Do not apply any swipeState, prior to setting original value")
        }
        
        if case .limit(let x) = swipeState {
            state.swipesLeft = x
        }
        else {
            state.swipesLeft = nil
        }
        
        self.swipeState = state
        
        return state
        
    }
    
}
