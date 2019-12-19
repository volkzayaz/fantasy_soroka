//
//  Analytics.swift
//  FantasyApp
//
//  Created by Soroka Vlad on 11.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Amplitude_iOS
import RxSwift

enum Analytics {}
extension Analytics {
    
    static func report(_ event: AnalyticsEvent) {
        Amplitude.instance()?.logEvent( event.name , withEventProperties: event.props )
        
//        print("Analytics:  Event = \(event.name)")
//        if let x = event.props {
//            print("Properties: \(event.props)")
//        }
    }

    static setUserProps( props: [String: String] ) {
        Amplitude.instance()?.setUserProperties( props )
    }
    
    static func report<T: AnalyticsNetworkRequest>(_ request: T) {
        
        _ = request.rx.request.subscribe()
        
        //print("Analytics: backend Request = \(request)")
        
    }
    
}
