//
//  FantasyDetailsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension FantasyDetailsViewModel {
    
    var title: String {
        return card.name
    }
    
    var description: String {
        return card.description
    }
    
    var likeText: Driver<String> {
        let c = card
        
        return appState.changesOf { $0.currentUser?.fantasies }
            .notNil()
            .map { fantasies in
                
                if fantasies.disliked.contains(c) {
                    return "Already Disliked"
                }
                
                if fantasies.liked.contains(c) {
                    return "Already liked"
                }
                
                return "Like"
                
            }
    }
    
}

struct FantasyDetailsViewModel : MVVM_ViewModel {

    private let card: Fantasy.Card
    private let positiveAction: FantasyCardInteraction.InteractionType
    
    init(router: FantasyDetailsRouter, card: Fantasy.Card) {
        self.router = router
        self.card = card
        
        if appStateSlice.currentUser?.fantasies.disliked.contains(card) ?? false {
            self.positiveAction = .dislike
        }
        else {
            self.positiveAction = .like
        }
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyDetailsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension FantasyDetailsViewModel {
    
    func likeButtonTapped() {
        
        ///TODO: clarify flipping rules on business logic side
        ///this is already too messy
        if case .like = positiveAction {
            
            if appStateSlice.currentUser?.fantasies.liked.contains(card) ?? false {
                Dispatcher.dispatch(action: NeutralFantasy(card: card))
            }
            else {
                Dispatcher.dispatch(action: LikeFantasy(card: card))
            }
            
        }
        else {
            
            if appStateSlice.currentUser?.fantasies.disliked.contains(card) ?? false {
                Dispatcher.dispatch(action: NeutralFantasy(card: card))
            }
            else {
                Dispatcher.dispatch(action: DislikeFantasy(card: card))
            }
            
        }
        
    }
    
}
