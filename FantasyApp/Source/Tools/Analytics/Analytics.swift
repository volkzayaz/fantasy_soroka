//
//  Analytics.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

public enum AnalyticsProvider {
    case amplitude
    // case firebase
    // case crashlytics
}

public protocol AnalyticsService {
    var provider: AnalyticsProvider { get }

    func report(event: String, withProperties properties: [String: Any])
    func report(view screen: AnalyticsScreen)
    func setUserProperty(_: Any, forKey: String)
}

protocol AnalyticsEvent {
    var providers: [AnalyticsProvider] { get }
    var name: [AnalyticsProvider: String] { get }
    var properties: [AnalyticsProvider: [String: Any]] { get }
}

class AnalyticsReporter {
    private let services: [AnalyticsService]

    static let `default` = AnalyticsReporter(services: [AmplitudeAnalyticsService()])

    init(services: [AnalyticsService]) {
        self.services = services
    }

    func report(event: AnalyticsEvent) {
        services
            .filter { event.providers.contains($0.provider) }
            .forEach { $0.report(event: event.name[$0.provider]!,
                                 withProperties: event.properties[$0.provider]!) }
    }

    func setUserProperty(_ value: Any, forKey key: String) {
        services.forEach { $0.setUserProperty(value, forKey: key) }
    }

    func report(view screen: AnalyticsScreen) {
        services.forEach { $0.report(view: screen) }
    }
}
