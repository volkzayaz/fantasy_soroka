//
//  PFObject+RX.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

/*
  1. Make model conform to ParsePresentable
  2. Fetch Model with PFQuery(predicate).rx.fetchAll<MyModel>()
                   or PFQuery(predicate).rx.fetchFirst<MyModel>()
  3. Create and Save Model to Parse with MyModel(data).rxCreate()
  4. Edit existing Models and save to Parse in one go with Array<MyModel>().rxSave()
 
 !!!Be aware, Encodable does not serialize nil values as null in json!!!
 struct A {
    var b: Int? nil
    var c: String = "abc"
 }
 
 would be coded into
 { "c": "abc" }
 
 not into
 { "c": "abc", "b": null }
 
 You can use custom encoding to work this around. Take a look at SwipeState implementation for custom encoding
*/
protocol ParsePresentable: Codable {
    static var className: String { get }
    var objectId: String? { get set }
}

extension ParsePresentable {
    static var query: PFQuery<PFObject> {
        return PFQuery(className: className)
    }
}

extension Reactive where Base: PFQuery<PFObject> {
    
    func fetchAll<T: ParsePresentable>() -> Single<[T]> {
        
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
        .asSingle()
        
    }
    
    func fetchFirst<T: ParsePresentable>() -> Single<T?> {
        return fetchAll().map { $0.first }
    }
    
}

extension Reactive where Base: PFQuery<PFObject> {
    
    func fetchAllObjects() -> Single<[PFObject]> {
        
        return Observable.create({ (subscriber) -> Disposable in
            
            self.base.findObjectsInBackground(block: { (maybeValues, error) in
                
                if let x = error {
                    subscriber.onError(x)
                    return
                }
                
                guard let parseObjects = maybeValues else {
                    fatalError("Parse result is neither error nor value")
                }
                
                subscriber.onNext( parseObjects )
                subscriber.onCompleted()
            })
            
            return Disposables.create {
                self.base.cancel()
            }
        })
            .asSingle()
        
    }
    
    func fetchFirstObject() -> Single<PFObject?> {
        return fetchAllObjects().map { $0.first }
    }
    
}

extension ParsePresentable {
    
    ///Suitable for creating PFObjects
    func rxCreate() -> Single<Self> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let e = JSONEncoder()
            e.dateEncodingStrategy = .iso8601
            
            guard let data = try? e.encode(self),
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
                
                var x = self
                x.objectId = pfObject.objectId!
                subscriber.onNext( x )
                subscriber.onCompleted()
            })
            
            return Disposables.create()
        }
        .asSingle()
        
    }
    
    ///Suitable for editing PFObject
    func rxSave() -> Single<Void> {
        return [self].rxSave()
    }
    
}

extension Array where Element: PFObject {
    
    func rxSave() -> Single<Void> {
        return Observable.create { (subscriber) -> Disposable in
            
            PFObject.saveAll(inBackground: self) { (didSave, maybeError) in
                
                if let e = maybeError {
                    subscriber.onError(e)
                    return
                }
                
                subscriber.onNext( () )
                subscriber.onCompleted()
            }
            
            return Disposables.create()
            }
            .asSingle()
    }
    
}
extension PFObject {
    
    func rxSave() -> Single<Void> {
        return [self].rxSave()
    }
    
}

extension Array where Element: ParsePresentable {
    
    ///Suitable for editing PFObjects
    func rxSave() -> Single<Void> {
        
        return map { parsePresentable in
            
            let e = JSONEncoder()
            e.dateEncodingStrategy = .iso8601
            
            guard let data = try? e.encode(parsePresentable),
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    fatalError("Incorrect representation of Codable \(parsePresentable)")
            }
            
            guard let objId = parsePresentable.objectId else {
                fatalError("Can't save object without objectId. Please use rxCreate() instead")
            }
            
            let object = PFObject(withoutDataWithClassName: type(of: parsePresentable).className,
                                  objectId: objId)
            
            object.setValuesForKeys(json)
            
            return object
        }
        .rxSave()
        
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
            
            jsons.append(json)
        }
        
        let e = JSONDecoder()
        e.dateDecodingStrategy = .iso8601
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsons, options: []),
            let result = try? e.decode([T].self, from: data) else {
                fatalError("Incorrect parsing of PFObjects")
        }
        
        return result
    }
    
}
