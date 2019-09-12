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
                if let entity = try responseProgress.response?.map(T.responseType.self) {
                    progress?(.value(entity))
                }
                else if let p = responseProgress.progressObject {
                    progress?(.progress(p))
                }
            } catch {
                // TODO: error handling for progress response mapping?
                debugPrint(error.localizedDescription)
            }
        }) { result in
            switch result {
            case .success(let response):
                do {
                    if let maybeError = try? response.map(GenericAPIError.self) {
                        return completion(.failure( FantasyError.apiError(maybeError) ) )
                    }
                    
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

extension APIProvider {
    public static let `default` = APIProvider(plugins: [NetworkLoggerPlugin(verbose: true)])
}

struct GenericAPIError: Decodable {
    let error: String
    let message: String
}
