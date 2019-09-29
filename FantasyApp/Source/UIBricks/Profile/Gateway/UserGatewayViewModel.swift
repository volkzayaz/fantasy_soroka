//
//  UserGatewayViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension UserGatewayViewModel {
    
    var name: Driver<String?> {
        return appState.changesOf { $0.currentUser?.bio.name }
    }

    var image: Driver<String> {
        return appState.changesOf { $0.currentUser?.bio.photos.main?.thumbnailURL }
            .map { $0 ?? "" }
    }
    
}

struct UserGatewayViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: UserGatewayRouter) {
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
    
    let router: UserGatewayRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension UserGatewayViewModel {
    
    
}
