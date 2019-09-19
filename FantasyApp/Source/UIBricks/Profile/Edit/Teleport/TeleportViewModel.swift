//
//  TeleportViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension TeleportViewModel {
    
    var dataSource: Driver<[SectionModel<String, Community>]> {
        
        return CommunityManager.allCommunities()
            .trackView(viewIndicator: indicator)
            .silentCatch()
            .asDriver(onErrorJustReturn: [])
            .map { communities in
                return [SectionModel(model: "", items: communities)]
            }
        
    }
    
    
}

struct TeleportViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    fileprivate let form: BehaviorRelay<EditProfileForm>
    
    init(router: TeleportRouter, form: BehaviorRelay<EditProfileForm>) {
        self.router = router
        self.form = form
        
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
    
    let router: TeleportRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension TeleportViewModel {
    
    func selected(community: Community) {
        
        var x = form.value
        x.teleportedCommunity = community
        form.accept(x)
        
        //Dispatcher.dispatch(action: UpdateCommunity(with: community))
        router.owner.navigationController?.popViewController(animated: true)
        
    }
    
}
