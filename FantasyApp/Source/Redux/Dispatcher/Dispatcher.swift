//
//  Dispatcher.swift
//  RhythmicRebellion
//
//  Created by Vlad Soroka on 2/8/19.
//  Copyright © 2019 All rights reserved.
//

import RxSwift
import RxCocoa

/* How to:
 
 1) Subscribe to changes: appState.drive { state in }
 2) Subscribe to partial changes: appState.changesOf { $0.currentUser.preferences.kinks }
 3) Get current AppState: appStateSlice.currentUser.preferences. ///Please never use it, chances are it can be reimplemented
                                                                    declarativelly using `appState: Driver<AppState>`
 4) Change appState: Dispatcher.dispatch( UpdateKinks( newKinks ) )
 5) Create Actions:
 struct UpdateKinks: Action {
 
    let newKinks: Set<Kink>
 
    func perform(state: AppState) -> AppState {
        var newState = state
        newState.user.preferences.kinks.intersect( with: newKinks )
        return newState
    }
 
 }
 6) Create Async Actions:
 struct LoadRooms: Action {
 
    let order: String
 
    func perform(state: AppState) -> Observable<AppState> {
 
        ///shoving placeholder rooms. For example, to show some placeholder UI
        var preState = state
        preState.user.connections.rooms = Room.fakes( 10 )
 
        return PFQuery.fetchSomeRooms(order: order)
                    .rx.fetchAll<[Room].self>()
                    .map {  rooms in
                        var newState = state
                        newState.user.connections.rooms = rooms
                        return newState
                    }
                    .startWith(preState) ///It's fine to push multiple values downstream. Just make sure
                                            to complete eveything within 10 seconds timeframe
    }

 }
 
 2 rules of Dispatcher:
 - Actions are executed serially one at a time
 - ActionCreators MUST return Completable observables. Action creator is given 10 seconds to finish it's job, otherwise it is terminated
 */

enum Dispatcher {
    
    static func dispatch(action: Action) {
        dispatch(action: ActionCreatorWrapper(action: action) )
    }
    
    static func dispatch(action: ActionCreator) {
        
        actions.onNext(action)
        
    }
    
    static let actions = BehaviorSubject<ActionCreator?>(value: nil)
    
    static func kickOff() -> Maybe<Void> {
        beginSerialExecution()
        
        return initAppState()
    }
    
    static func beginSerialExecution() {
        ///Serial execution
        let _ =
        actions.notNil().concatMap { actionCreator -> Observable<AppState> in
            
            let forceCompleteTrigger = Observable.just( () ).delay(10, scheduler: MainScheduler.instance)
                .do(onNext: {
                    fatalErrorInDebug("Action \(actionCreator) exceeded 10 seconds quota to update appState. State that was mutated: \(String(describing: state.value)) ")
                })
            
            return Observable.deferred { () -> Observable<AppState> in
                    print("Dispatching \(actionCreator.description)")
                    return actionCreator.perform(initialState: state.value!)
                }
                .takeUntil(forceCompleteTrigger)
                .catchError { (error) -> Observable<AppState> in
                    fatalError("Action \(actionCreator.description) has errored which is unsupported. Error \(error)")
                }
            
            }
            .filter { $0 != state.value! }
            .bind(to: state)
    }
}

extension Driver where Element == AppState {
    
    func changesOf<T: Equatable>( mapper: @escaping (AppState) -> T) -> SharedSequence<SharedSequence.SharingStrategy, T> {
        return map(mapper).distinctUntilChanged()
    }
    
}
