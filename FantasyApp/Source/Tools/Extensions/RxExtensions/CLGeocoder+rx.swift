//
//  CLGeocoder+rx.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

extension CLGeocoder {
    var rx: Reactive<CLGeocoder> {
        return Reactive(self)
    }
}

extension Reactive where Base == CLGeocoder {

    func city(near: CLLocation) -> Single<String?> {
        
        return Observable.create { (observer) -> Disposable in
            
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(near) { (maybePlacemarks, maybeError) in
                guard let placemarks = maybePlacemarks, maybeError == nil else {
                    observer.onError(maybeError!)
                    return
                }

                observer.onNext(placemarks.compactMap { $0.locality }.first)
                observer.onCompleted()
                
            }
            
            return Disposables.create { geocoder.cancelGeocode() }
        }
        .asSingle()
        
    }
    
}

