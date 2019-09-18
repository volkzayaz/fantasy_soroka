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

    func cities(near: CLLocation) -> Single<String> {
        
        return Observable.create { (observer) -> Disposable in
            
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(near) { (maybePlacemarks, maybeError) in
                guard maybeError == nil else {
                    observer.onError(maybeError!)
                    return
                }

                let x = maybePlacemarks?.map { $0.locality }
                
                print(x)

//                var results: [SearchLocation] = []
//
//                if let placemark = maybePlacemarks?.first {
//                    results.append(SearchLocation(county: placemark.country,
//                                                  city: placemark.locality))
//                }
//
//                if let c = maybePlacemarks?.count, c > 1 {
//                    let placemark = maybePlacemarks![1]
//                    results.append(SearchLocation(county: placemark.country,
//                                                  city: placemark.locality))
//                }
//
//                observer.onNext(results)
                observer.onCompleted()
                
            }
            
            return Disposables.create { geocoder.cancelGeocode() }
        }
        .asSingle()
        
    }
    
}

