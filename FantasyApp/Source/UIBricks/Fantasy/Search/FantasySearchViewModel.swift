//
//  FantasySearchViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension FantasySearchViewModel {
    
    var dataSource: Driver<[AnimatableSectionModel<String, Model>]> {

        return searchQuery.asDriver().flatMapLatest { q -> Driver<([Fantasy.Card], Int)> in
            
            let swipeLimit = appState.changesOf { $0.fantasies.restriction }
            
            let query = Fantasy.Manager.searchFor(query: q).asDriver(onErrorJustReturn: [])
                .debounce(.milliseconds(300))
            
            return Driver.combineLatest(query, swipeLimit) { (cards, restriction) in
                    guard case .swipeCount(let x) = restriction else {
                        return (cards, 0)
                    }
                    
                    return (cards, x)
                }
            
        }
        .map { (cards, limit) in
            
            let models = cards.enumerated().map { (index, card) in
                return Model(card: card, isBlurred: index >= limit)
            }
            
            return [AnimatableSectionModel(model: "",
                                           items: models)]
        }
    }
    
    struct Model: IdentifiableType, Equatable {
        let card: Fantasy.Card
        let isBlurred: Bool
        
        var identity: String {
            return card.text
        }
    }
    
}

struct FantasySearchViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    private let searchQuery = BehaviorRelay<String>(value: "")
    
    init(router: FantasySearchRouter) {
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
    
    let router: FantasySearchRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension FantasySearchViewModel {
    
    func searchQueryChanged(x: String) {
        searchQuery.accept(x)
    }
    
    func modelTapped(model: Model) {
        
        if model.isBlurred { return }
        
        router.cardTapped(card: model.card)
    }
    
}
