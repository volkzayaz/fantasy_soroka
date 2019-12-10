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
        return collections.asDriver().map { collections in
            return [AnimatableSectionModel(model: "", items: collections)]
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
        
                return Driver<Int>.interval(.seconds(1)).startWith(0).map { _ in
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
        return collections.asDriver().map { collections in
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
        
        let p = provider
        
        return reloadTrigger.asDriver()
            .flatMapLatest { _ in p.cardsChange }
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
    
    var subscribeButtonHidden: Driver<Bool> {
        return appState.changesOf { $0.currentUser?.subscription.isSubscribed }
            .map { $0 ?? false }
    }
    
}

struct FantasyDeckViewModel : MVVM_ViewModel {
    
    let provider: FantasyDeckProvier

    private let reloadTrigger = BehaviorRelay(value: ())
    
    fileprivate let cardTrigger = BehaviorRelay<Fantasy.Card?>(value: nil)
    fileprivate let collections = BehaviorRelay<[Fantasy.Collection]>(value: [])
    fileprivate var viewTillOpenCardTimer = TimeSpentCounter()
    
    init(router: FantasyDeckRouter, provider: FantasyDeckProvier = MainDeckProvider()) {
        self.router = router
        self.provider = provider
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)

        appState.changesOf { $0.currentUser?.fantasies.purchasedCollections }
            .asObservable()
            .flatMapLatest { _ -> Single<[Fantasy.Collection]> in
                return Fantasy.Manager.fetchCollections()
            }
            .map { $0.filter { !$0.isPurchased } }
            .silentCatch(handler: router.owner)
            .bind(to: collections)
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
        
        PurchaseManager.purhcaseSubscription()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe()
            .disposed(by: bag)
        
    }
    
    mutating func cardTapped(card: Fantasy.Card) {
        
        let shouldTrigger = provider.pessimisticReload
        
        router.cardTapped(provider: provider.detailsProvider(card: card, reactionCallback: { [unowned x = reloadTrigger] in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if shouldTrigger {
                    x.accept( () )
                }
            }
            
        }))
        
        Analytics.report(Analytics.Event.CardOpenTime(card: card,
                                                      context: provider.navigationContext,
                                                      spentTime: viewTillOpenCardTimer.finish()))
        
        ///it's actually wrong. Timer restart should happen on next viewWillApper
        ///but we can't receive this event because of how Boris implemented Card Details presentation
        ///view lifecycle events are not passed through
        viewTillOpenCardTimer.restart()
    }

    func show(collection: Fantasy.Collection) {
        router.show(collection: collection)
    }
    
    mutating func cardShown(card: Fantasy.Card) {
        viewTillOpenCardTimer.start()
    }
    
}

//MARK:- Tutorial

extension FantasyDeckViewModel {
    var showTutorial: Bool {
        get {
            return SettingsStore.showFantasyCardTutorial.value
        }
        set {
            SettingsStore.showFantasyCardTutorial.value = newValue
        }
    }
}
