//
//  PFObject+RX.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

///NPLUser.user.rx.query(predicate)
///  .map { $0.name }
///  .bind(to: userNameLabel.rx.text)

extension Reactive where Base: PFObject {
    
    func query<T: PFObject>(with predicate: NSPredicate) -> Maybe<[T]> {
        
        return Observable.create({ (subscriber) -> Disposable in
        
            let q = T.query(with: predicate)!
                
            q.findObjectsInBackground(block: { (values, error) in
                
                if let e = error {
                    subscriber.onError(e)
                    return
                }
                
                subscriber.onNext( values as! [T] )
                subscriber.onCompleted()
            })
            
            return Disposables.create {
                q.cancel()
            }
        })
        .asMaybe()
        
    }
    
}


extension PFObject {
    
    var rx: Reactive<PFObject> {
        return Reactive(self)
    }
    
}
