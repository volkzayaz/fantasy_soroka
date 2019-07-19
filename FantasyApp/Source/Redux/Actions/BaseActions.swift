//
//  Base.swift
//
//  Created by Vlad Soroka on 3/18/19.
//  Copyright © 2019
//

import Foundation

import RxSwift
import RxCocoa

///Syncrhonous action
protocol Action {
    func perform( initialState: AppState ) -> AppState
}

///Asyncrhonous action
protocol ActionCreator: CustomStringConvertible {
    
    ///Make sure your Observable eventually completes.
    ///Non completable observables will block the whole execution Queue
    func perform( initialState: AppState ) -> Observable<AppState>
}

extension ActionCreator {
    
    var description: String {
        return "\(type(of: self))"
    }
    
}

////Wrapper for syncronous action
struct ActionCreatorWrapper: ActionCreator {
    let action: Action
    
    func perform(initialState: AppState) -> Observable<AppState> {
        return .just( action.perform(initialState: initialState) )
    }
    
    var description: String {
        return ":\(type(of: action))"
    }
    
}
