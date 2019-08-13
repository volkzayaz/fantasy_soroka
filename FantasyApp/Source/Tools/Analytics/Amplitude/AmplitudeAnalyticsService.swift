//
//  AmplitudeAnalyticsService.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Amplitude_iOS

class AmplitudeAnalyticsService: AnalyticsService {
    var provider: AnalyticsProvider = .amplitude

    func report(event: String, withProperties properties: [String: Any]) {
        Amplitude.instance()?.logEvent(event, withEventProperties: properties)
    }

    func setValue(_ value: Any, forProperty property: AnalyticsUserProperty) {
        guard let value = value as? NSObject else {
            fatalError("Amplitude user properties should always inherit from NSObject")
        }
        let identify = AMPIdentify().set(property.rawValue, value: value)
        Amplitude.instance()?.identify(identify)
    }

    func report(view screen: AnalyticsScreen) {
        Amplitude.instance()?.logEvent("View \(screen.rawValue)")
    }
}
