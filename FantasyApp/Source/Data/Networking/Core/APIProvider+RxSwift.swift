//
//  APIProvider+RxSwift.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

public extension Reactive where Base: APIProviderType {

    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func request<T: APIResource>(_ resource: T, callbackQueue: DispatchQueue? = nil) -> Single<T.responseType> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(resource, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.error(error))
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }

    /// Designated request-making method with progress.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Progress response object observable.
    func requestWithProgress<T: APIResource>(_ resource: T, callbackQueue: DispatchQueue? = nil)
        -> Observable<ResponseProgress<T.responseType>> {
            let response: Observable<ResponseProgress<T.responseType>> = Observable.create { [weak base] observer in
                let cancellableToken = base?.request(resource,
                                                     callbackQueue: callbackQueue,
                                                     progress: { progress in
                    observer.onNext(progress)
                }) { result in
                    switch result {
                    case .success:
                        observer.onCompleted()
                    case let .failure(error):
                        observer.onError(error)
                    }
                }

                return Disposables.create {
                    cancellableToken?.cancel()
                }
            }

            // Accumulate all progress and combine them when the result comes
            return response.scan(ResponseProgress<T.responseType>()) { last, progress in
                let progressObject = progress.progressObject ?? last.progressObject
                let response = progress.response ?? last.response
                return ResponseProgress(progress: progressObject, response: response)
            }
    }
}
