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
                
                if state.cards == nil || (state.cards?.count ?? 0) > 0 {
                    return .swipeCards
                }
                return .waiting
        }
    }
    
    var timeLeftText: Driver<NSAttributedString> {
        
        return provider.cardsChange
            .map { x -> Date? in
                return x.wouldUpdateAt
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
        
        return provider.cardsChange
            .map { $0.cards }
            .notNil()
        
    }
    
    
    
    var mutualCardTrigger: Driver<Fantasy.Card> {
        return cardTrigger.asDriver().notNil()
    }
    
    var subscribeButtonHidden: Driver<Bool> {
        return appState.changesOf { $0.currentUser?.subscription.isSubscribed }
            .map { $0 ?? false }
    }
    
    var showTutorial: Driver<Bool> {
        return Driver.combineLatest(SettingsStore.showFantasyCardTutorial.observable.asDriver(onErrorJustReturn: false),
                                    mode) { (a, b) -> Bool in
            return a && b != Mode.waiting
        }
    }
    
}

struct FantasyDeckViewModel : MVVM_ViewModel {

    typealias PresentationStyle = FantasyDeckViewController.PresentationStyle

    let presentationStyle: PresentationStyle
    let provider: FantasyDeckProvier
    let room: Room?

    fileprivate let cardTrigger = BehaviorRelay<Fantasy.Card?>(value: nil)
    fileprivate let collections = BehaviorRelay<[Fantasy.Collection]>(value: [])
    fileprivate var viewTillOpenCardTimer = TimeSpentCounter()

    init(router: FantasyDeckRouter, provider: FantasyDeckProvier = MainDeckProvider(), presentationStyle: PresentationStyle  = .stack, room: Room? = nil) {
        self.router = router
        self.provider = provider
        self.presentationStyle = presentationStyle
        self.room = room
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)

        appState.changesOf { $0.currentUser?.fantasies.purchasedCollections }
            .notNil()
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
        router.showSubscription()
    }
    
    mutating func cardTapped(card: Fantasy.Card) {
        
        router.cardTapped(provider: provider.detailsProvider(card: card))
        
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

    func updateTutorial(showNextTime: Bool)  {
        SettingsStore.showFantasyCardTutorial.value = showNextTime
    }

}

//MARK:- Room

extension FantasyDeckViewModel {

    func presentMe() {
        guard let r = room else { return }

        presentUser(id: r.me.userSlice.id)
    }

    func presentPeer() {
        guard let r = room else { return }

        presentUser(id: r.peer.userSlice.id)
    }

   private func presentUser(id: String) {
        UserManager.getUser(id: id)
        .silentCatch(handler: router.owner)
        .subscribe(onNext: { user in
            self.router.showUser(user: user)
        })
        .disposed(by: bag)
    }
}
