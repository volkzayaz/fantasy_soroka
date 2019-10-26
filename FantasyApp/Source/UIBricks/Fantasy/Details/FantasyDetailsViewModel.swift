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
    
    var description: String { return card.text }
    var dislikesCount: Int { return card.dislikes }
    var likesCount: Int { return card.likes }
    var imageURL: String { return card.imageURL }

}

struct FantasyDetailsViewModel: MVVM_ViewModel {

    private let card: Fantasy.Card
    private let shouldDecrement: Bool

    let currentState: BehaviorRelay<Fantasy.Card.Reaction>
    
    init(router: FantasyDetailsRouter, card: Fantasy.Card, shouldDecrement: Bool) {
        self.router = router
        self.card = card
        self.shouldDecrement = shouldDecrement
        self.currentState = BehaviorRelay(value: card.reaction)
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyDetailsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()

    private func determineFlipUpAction() {

    }
    
}

extension FantasyDetailsViewModel {
    
    func likeCard() {
        var reaction = currentState.value

        switch currentState.value {
        case .like:
            Dispatcher.dispatch(action: NeutralFantasy(card: card))
            reaction = .neutral
        case .neutral, .dislike:
            Dispatcher.dispatch(action: LikeFantasy(card: card, shouldDecrement: shouldDecrement))
            reaction = .like
        default:
            break
        }
        
        currentState.accept(reaction)
    }

    func dislikeCard() {
        var reaction = currentState.value

        switch currentState.value {
        case .dislike:
            Dispatcher.dispatch(action: NeutralFantasy(card: card))
            reaction = .neutral
        case .neutral, .like:
            Dispatcher.dispatch(action: DislikeFantasy(card: card, shouldDecrement: shouldDecrement))
            reaction = .dislike
        default:
            break
        }

        currentState.accept(reaction)
    }

    func close() {
        router.close()
    }
    
}
