//
//  APIProvider.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public protocol APIProviderType: class {
    @discardableResult func request<T: APIResource>(
        _ resource: T,
        callbackQueue: DispatchQueue?,
        progress: ((ResponseProgress<T.responseType>) -> Void)?,
        completion: @escaping (_ result: Result<T.responseType, Error>) -> Void) -> Cancellable
}

open class APIProvider: MoyaProvider<MultiTarget>, APIProviderType {
    @discardableResult public func request<T: APIResource>(
        _ resource: T,
        callbackQueue: DispatchQueue? = .none,
        progress: ((ResponseProgress<T.responseType>) -> Void)? = .none,
        completion: @escaping (_ result: Result<T.responseType, Error>) -> Void) -> Cancellable {

        return super.request(.target(resource), callbackQueue: callbackQueue, progress: { responseProgress in
            do {
                let entity = try responseProgress.response?.map(T.responseType.self)
                progress?(ResponseProgress(progress: responseProgress.progressObject, response: entity))
            } catch {
                // TODO: error handling for progress response mapping?
                debugPrint(error.localizedDescription)
            }
        }) { result in
            switch result {
            case .success(let response):
                do {
                    let entity = try response.map(T.responseType.self)
                    completion(.success(entity))
                } catch {
                    completion(.failure(MoyaError.jsonMapping(response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension APIProvider: ReactiveCompatible {
    public static let `default` = APIProvider(plugins: [NetworkLoggerPlugin(verbose: true)]).rx
}

