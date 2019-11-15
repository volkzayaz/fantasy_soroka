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
            
            if let p = responseProgress.progressObject {
                progress?(.progress(p))
            }
            
        }) { result in
            switch result {
            case .success(let response):
                
                if let maybeError = try? response.map(GenericAPIError.self) {
                    return completion(.failure( FantasyError.apiError(maybeError) ) )
                }
                
                let entity: T.responseType
                do {
                    entity = try response.mapFantasyResponse()
                } catch (let e) {
                    print(e)
                    return completion(.failure(MoyaError.jsonMapping(response)))
                }
                
                completion(.success(entity))
                
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
    }
}

extension APIProvider {
    public static let `default` = APIProvider(plugins: [
        NetworkLoggerPlugin(verbose: true)
    ])
}

struct GenericAPIError: Decodable {
    let error: String
    let message: String
}

extension Moya.Response {
    
    struct Wrapped<T: Decodable> : Decodable {
        let value: T
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter
    }()
    
    func mapFantasyResponse<T: Decodable>() throws -> T {
        
        ///We just want to represent Empty data response
        /// as Optional<T>
        ///while Moya's default behaviour in such case is Error
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { (decoder) -> Date in
            let string = try (try decoder.singleValueContainer()).decode(String.self)
            return Moya.Response.dateFormatter.date(from: string)!
        }
        
        guard data.count > 0 else {
            
            let fakeJSONData = """
                                { "value": null }
                               """.data(using: .utf8)!
            
            do {
                return (try decoder.decode(Wrapped<T>.self, from: fakeJSONData)).value
            } catch {
                throw FantasyError.generic(description: "Can't map \(String(describing: T.self)) from empty response")
            }
            
        }
        
        
        do {
            return try decoder.decode(T.self, from: data)
        }
        catch (let e) { throw e }
        
        
    }
    
}

///TODO: this should really be just Void
struct EmptyResponse: Codable {}
