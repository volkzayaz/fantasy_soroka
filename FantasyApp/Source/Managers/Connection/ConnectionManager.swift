//
//  ConnectionManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum ConnectionManager {}
extension ConnectionManager {
    
    static func relationStatus(with user: User) -> Single<Connection> {
        return GetConnection(with: user).rx.request
            .map { $0.toNative }
    }
    
    static func like(user: User) -> Single<Void> {
        return UpsertConnection(with: user, type: .like)
            .rx.request.map { _ in }
    }
    
    static func likeBack(user: User) -> Single<Void> {
        return AcceptConnection(with: user, type: .like)
            .rx.request.map { _ in }
    }
    
    static func reject(user: User) -> Single<Void> {
        return RejectConnection(with: user)
            .rx.request.map { _ in }
    }
    
}
