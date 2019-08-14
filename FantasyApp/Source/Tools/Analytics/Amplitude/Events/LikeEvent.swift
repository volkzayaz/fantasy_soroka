//
//  LikeEvent.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

// AnalyticsReporter.default.report(event: LikeEvent(accountId: "ACCOUNT_ID"))
struct LikeEvent: AnalyticsEvent {
    var providers: Set<AnalyticsProvider> {
        return [.amplitude]
    }

    var name: [AnalyticsProvider: String] {
        return [.amplitude: "a_like_profile"]
    }

    var properties: [AnalyticsProvider : [String : Any]] {
        return [.amplitude: ["account_id": accountId]]
    }

    let accountId: String
}
