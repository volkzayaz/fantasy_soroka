//
//  FantasyCollectionViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/21/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension FantasyCollectionViewModel {
    
    var dataSource: Driver<[AnimatableSectionModel<String, Fantasy.Collection>]> {
    
        return Fantasy.Manager.fetchCollections()
            .silentCatch(handler: router.owner)
            .trackView(viewIndicator: indicator)
            .asDriver(onErrorJustReturn: [])
            .map { x in
                return [AnimatableSectionModel(model: "",
                                               items: x)]
            }
        
    }
    
}

struct FantasyCollectionViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: FantasyCollectionRouter) {
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
    
    let router: FantasyCollectionRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension FantasyCollectionViewModel {
    
    func collectionTapped(collection: Fantasy.Collection) {
        
        router.owner.showDialog(title: "Buy Collection", text: "To check all fantasies inside?", style: .alert,
                                positiveText: "Pay 1.29$") { [weak o = router.owner] in
                                    Dispatcher.dispatch(action: BuyCollection(collection: collection))
                                    o?.navigationController?.popViewController(animated: true)
        }
        
    }
    
}
