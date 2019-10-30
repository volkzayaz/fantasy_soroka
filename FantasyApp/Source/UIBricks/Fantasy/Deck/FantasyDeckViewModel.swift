//
//  FantasyDeckViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension FantasyDeckViewModel {

    var collectionsDataSource: Driver<[AnimatableSectionModel<String, Fantasy.Collection>]> {
        return collectionsTrigger.asDriver().map { collections in
            return [AnimatableSectionModel(model: "", items: collections.filter { !$0.isPurchased })]
        }
    }
    
    enum Mode {
        case swipeCards, waiting
    }

    var mode: Driver<Mode> {
        return provider.cardsChange
            .map { state in
                
                if case .cards(_) = state {
                    return .swipeCards
                }
                return .waiting
            }
    }
    
    var timeLeftText: Driver<NSAttributedString> {
        
        return provider.cardsChange
            .map { x -> Date? in
                if case .empty(let date) = x {
                    return date
                }
                return nil
            }
            .notNil()
            .flatMapLatest { date in
        
                return Driver<Int>.interval(.seconds(1)).map { _ in
                    let string = date.toTimeLeftString()
                    let attributedString = NSMutableAttributedString(string: string)
                    attributedString.addAttribute(.foregroundColor,
                                                  value: UIColor.fantasyPink,
                                                  range: (string as NSString).range(of: string))
                    return attributedString
                }
                
            }
        
    }

    var collectionsCountText: Driver<NSAttributedString> {
        return collectionsTrigger.asDriver().map { collections in
            let count = collections.filter { !$0.isPurchased }.count
            let string = R.string.localizable.fantasyDeckCollectionsCount(count)
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.fantasyPink,
                range: (string as NSString).range(of: "\(count)")
            )
            return attributedString
        }
    }
    
    var cards: Driver<[Fantasy.Card]> {
        return provider.cardsChange
            .map { deck in
                switch deck {
                case .cards(let cards): return cards
                case .empty(_): return []
                }
            }
    }
    
    var mutualCardTrigger: Driver<Fantasy.Card> {
        return cardTrigger.asDriver().notNil()
    }
    
}

struct FantasyDeckViewModel : MVVM_ViewModel {
    
    let provider: FantasyDeckProvier

    fileprivate let cardTrigger = BehaviorRelay<Fantasy.Card?>(value: nil)
    fileprivate let collectionsTrigger = BehaviorRelay<[Fantasy.Collection]>(value: [])
    
    init(router: FantasyDeckRouter, provider: FantasyDeckProvier = MainDeckProvider()) {
        self.router = router
        self.provider = provider
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)

        Fantasy.Manager.fetchCollections()
            .silentCatch(handler: router.owner)
            .bind(to: collectionsTrigger)
            .disposed(by: bag)

    }
    
    let router: FantasyDeckRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    

}

extension FantasyDeckViewModel {
    
    enum SwipeDirection { case left, right, down }

    func swiped(card: Fantasy.Card, direction: SwipeDirection) {
        provider.swiped(card: card, in: direction) { [unowned x = cardTrigger] in
            x.accept(card)
        }
    }

    func subscribeTapped() {

    }
    
    func cardTapped(card: Fantasy.Card) {
        router.cardTapped(card: card)
    }

    func show(collection: Fantasy.Collection) {
        router.show(collection: collection)
    }
    
}
