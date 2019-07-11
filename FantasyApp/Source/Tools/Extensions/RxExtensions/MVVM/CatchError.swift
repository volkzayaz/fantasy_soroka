//
//  CatchError.swift
//     
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016    All rights reserved.
//

import RxSwift

extension ObservableConvertibleType {

    private var identifier : String { return "com.rx.extensions.erroridentifier" }
    
    func silentCatch<T: CanPresentMessage>
        (handler: T?) -> Observable<Element> where T: AnyObject {
        
        return self.asObservable()
            .map { Result.success($0) }
            .catchError { [weak h = handler] (error) -> Observable<Result<Element, Error>> in
            
                DispatchQueue.main.async {
                    h?.present(error: error)
                }
                
                return .never()
            }
            .filter {
                switch $0 {
                case .success(_): return true
                case .failure(_): return false
                }
                
            }
            .map {
                switch $0 {
                case .success(let val): return val
                case .failure(_): fatalError("Shouldn't have recovered from filter")
                }
        }
    }

    func silentCatch() -> Observable<Element> {
        return self.silentCatch(handler: nil as MockCanPresentMessage?)
    }
    
}

private class MockCanPresentMessage : NSObject, CanPresentMessage {
    func presentMessage(message: DisplayMessage) {}
}


