//
//  UserProfileViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension UserProfileViewModel {
    
    var tempLocation: Driver<String> {
        return appState.changesOf { $0.lastKnownLocation }
            .map { $0 == nil ? "Don't know where you are" : $0!.description }
    }
 
}

struct UserProfileViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: UserProfileRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: UserProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension UserProfileViewModel {
    
    func logout() {
        AuthenticationManager.logout()
        Dispatcher.dispatch(action: SetUser(user: nil))
    }
    
}
