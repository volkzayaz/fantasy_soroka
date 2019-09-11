//
//  PFObject+RX.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import Parse

/*
  1. Make model conform to ParsePresentable
  2. Fetch Model with PFQuery(predicate).rx.fetchAll<MyModel>()
                   or PFQuery(predicate).rx.fetchFirst<MyModel>()
  3. Create and Save Model to Parse with MyModel(data).rxCreate()
  4. Edit existing Models and save to Parse in one go with Array<MyModel>().rxSave()
*/
protocol ParsePresentable: Codable {
    static var className: String { get }
    var pfObjectId: String { get }
}

extension Reactive where Base: PFQuery<PFObject> {
    
    func fetchAll<T: ParsePresentable>() -> Maybe<[T]> {
        
        return Observable.create({ (subscriber) -> Disposable in
            self.base.findObjectsInBackground(block: { (maybeValues, error) in
                
                if let x = error {
                    subscriber.onError(x)
                    return
                }
                
                guard let parseObjects = maybeValues else {
                    fatalError("Parse result is neither error nor value")
                }
                
                subscriber.onNext( parseObjects.toCodable() )
                subscriber.onCompleted()
            })
            
            return Disposables.create {
                self.base.cancel()
            }
        })
        .asMaybe()
        
    }
    
    func fetchFirst<T: ParsePresentable>() -> Maybe<T?> {
        return fetchAll().map { $0.first }
    }
    
}

extension ParsePresentable {
    
    ///Suitable for creating PFObjects
    func rxCreate() -> Maybe<Void> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            guard let data = try? JSONEncoder().encode(self),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                fatalError("Incorrect representation of Codable \(self)")
            }
            
            let pfObject = PFObject(className: type(of: self).className,
                                    dictionary: json)
            
            pfObject.saveInBackground(block: { (didSave, maybeError) in
                
                if let e = maybeError {
                    subscriber.onError(e)
                    return
                }
                
                subscriber.onNext( () )
                subscriber.onCompleted()
            })
            
            return Disposables.create()
        }
        .asMaybe()
        
    }
    
    ///Suitable for editing PFObject
    func rxSave() -> Maybe<Void> {
        return [self].rxSave()
    }
    
}

extension Array where Element: ParsePresentable {
    
    ///Suitable for editing PFObjects
    func rxSave() -> Maybe<Void> {
        return Observable.create { (subscriber) -> Disposable in
            
            let pfObjects: [PFObject] = self.map { parsePresentable in
                
                guard let data = try? JSONEncoder().encode(parsePresentable),
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        fatalError("Incorrect representation of Codable \(parsePresentable)")
                }
                
                let object = PFObject(withoutDataWithClassName: type(of: parsePresentable).className,
                                      objectId: parsePresentable.pfObjectId)
                
                object.setValuesForKeys(json)
                
                return object
            }
            
            PFObject.saveAll(inBackground: pfObjects) { (didSave, maybeError) in
                
                if let e = maybeError {
                    subscriber.onError(e)
                    return
                }
                
                subscriber.onNext( () )
                subscriber.onCompleted()
            }
            
            return Disposables.create()
            }
            .asMaybe()
    }
    
}

extension Array where Element: PFObject {
    
    func toCodable<T: Codable>() -> [T] {
        
        var jsons: [[String: Any]] = []
        
        self.forEach { (pfObject) in
            
            var json: [String: Any] = [:]
            
            for key in pfObject.allKeys {
                json[key] = pfObject[key]
            }
            json["objectId"] = pfObject.objectId
            json["updatedAt"] = pfObject.updatedAt
            json["createdAt"] = pfObject.createdAt
            
            jsons.append(json)
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsons, options: []),
            let result = try? JSONDecoder().decode([T].self, from: data) else {
                fatalError("Incorrect parsing of PFObjects")
        }
        
        return result
    }
    
}
