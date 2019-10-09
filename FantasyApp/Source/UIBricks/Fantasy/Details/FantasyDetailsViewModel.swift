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
        return "FantasyCard has no name by definition"
    }
    
    var description: String {
        return card.text
    }
    
    var likeText: Driver<String> {
        
        let flipUp = flipUpAction
        
        return currentState.asDriver()
            .map { reaction -> String in
                
                switch flipUp {
                
                case .neutral: return ""
                    
                case .like   : return reaction == .neutral ? "Like"    : "Already liked"
                case .dislike: return reaction == .neutral ? "Dislike" : "Already disliked"
                case .block  : return reaction == .neutral ? "Block"   : "Already blocked"
                }
                
            }
    }
    
}

struct FantasyDetailsViewModel : MVVM_ViewModel {

    private let card: Fantasy.Card
    private let shouldDecrement: Bool
    
    private let currentState: BehaviorRelay<Fantasy.Card.Reaction>
    
    private let flipUpAction: Fantasy.Card.Reaction
    
    init(router: FantasyDetailsRouter, card: Fantasy.Card, shouldDecrement: Bool) {
        self.router = router
        self.card = card
        self.shouldDecrement = shouldDecrement
        
        self.currentState = BehaviorRelay(value: card.reaction)
        
        switch card.reaction {
        case .neutral, .like:
            flipUpAction = .like
            
        case .block:
            flipUpAction = .block
            
        case .dislike:
            flipUpAction = .dislike
        
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
        
        if currentState.value != .neutral {
            
            Dispatcher.dispatch(action: NeutralFantasy(card: card))
            currentState.accept( .neutral )
            return
            
        }
        
        switch flipUpAction {
        case .neutral: break;
        case .like:
            Dispatcher.dispatch(action: LikeFantasy(card: card, shouldDecrement: shouldDecrement))
            
        case .dislike:
            Dispatcher.dispatch(action: DislikeFantasy(card: card, shouldDecrement: shouldDecrement))
            
        case .block:
            ///TODO: dispatch block fantasy
            break
            
        }
        
        currentState.accept( flipUpAction )
         
        
    }
    
}
