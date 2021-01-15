//
//  Reactive+CLLocationManager.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 15.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import RxSwift

extension Reactive where Base : CLLocationManager {
    
    var validatedLocation: RxSwift.Observable<CLLocation?> {
        location.map {
            if (RunScheme.debug || RunScheme.adhoc) && SettingsStore.disableLastKnownLocationUpdate.value {
                return RemoteConfigManager.fakeLocation.clLocation
            } else {
                return $0
            }
        }
    }
}

