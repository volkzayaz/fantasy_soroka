//
//  APIProvider+RxSwift.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

///Usage: MyCustomApiResource().rx.request
public extension Reactive where Base: APIResource {

    var request: Single<Base.responseType> {
        
        return requestWithProgress
            .map { x -> Base.responseType? in
                switch x {
                case .value(let t): return t
                case .progress(_): return nil
                }
            }
            .notNil()
            .asSingle()
        
    }

    var requestWithProgress: Observable<ResponseProgress<Base.responseType>> {
    
            return Observable.create { observer in
                
                ///if needed APIProvider can be injected using parameters of this function
                let token = APIProvider.default.request(self.base,
                                                        callbackQueue: nil,
                                                        progress: { progress in
                                                            observer.onNext(progress)
                }, completion: { result in
                    switch result {
                    case .success       : observer.onCompleted()
                    case .failure(let e): observer.onError(e)
                    }
                })

                return Disposables.create {
                    token.cancel()
                }
            }

    }
}

