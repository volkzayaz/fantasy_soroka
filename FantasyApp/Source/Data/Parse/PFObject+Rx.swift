//
//  PFObject+RX.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: PFQuery<PFObject> {
    
    func fetchAll<T: Codable>() -> Maybe<[T]> {
        
        return Observable.create({ (subscriber) -> Disposable in
        
            self.base.findObjectsInBackground(block: { (maybeValues, error) in
                
                if let e = error {
                    subscriber.onError(e)
                    return
                }
                
                guard let v = maybeValues else {
                    fatalError("Parse result is neither error nor value")
                }
                
                var jsons: [[String: Any]] = []
                
                v.forEach { (pfObject) in
                    
                    var json: [String: Any] = [:]
                    
                    for key in pfObject.allKeys + ["objectId"] {
                        json[key] = pfObject[key]
                    }
                    
                    jsons.append(json)
                }
                
                guard let data   = try? JSONSerialization.data(withJSONObject: jsons, options: []),
                      let result = try? JSONDecoder().decode([T].self, from: data) else {
                    fatalError("Incorrect parsing of PFObjects")
                }
                
                subscriber.onNext( result )
                subscriber.onCompleted()
            })
            
            return Disposables.create {
                self.base.cancel()
            }
        })
        .asMaybe()
        
    }
    
    func fetchFirst<T: Codable>() -> Maybe<T?> {
        return fetchAll().map { $0.first }
    }
    
}
