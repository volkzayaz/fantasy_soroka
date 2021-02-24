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

import Branch
import StoreKit


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
        return .just(.swipeCards)
    }
    
    var unlockAllDecksButtonHidden: Driver<Bool> {
        
        return subscribeButtonHidden.map { [unowned self] isSubsribed in
            if !isSubsribed && room?.value == nil  {
                return false
            }
            
            return true
        }
    }
    
    var isPlayRoomPage: Driver<Bool> {
        guard let _ = room?.value else { return .just(false) }
        
        return .just(true)
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
    
    var sortedFantasies:  Driver<[[Fantasy.Collection]]> {
        
        return Driver.combineLatest(User.changesOfSubscriptionStatus,
                             appState.changesOf { $0.currentUser?.fantasies.purchasedCollections },
                             collections.asDriver())
            .map { (_, _, collections) -> [[Fantasy.Collection]] in
                return collections.group(by: \.groupCategory)
            }
    }

    var collectionsCountText: Driver<NSAttributedString> {
        return collections.asDriver().map { collections in
            let count = collections.count
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
        
        guard let x = room else {
            return .just([])
        }
        
        return x.distinctUntilChanged { $0.settings.sharedCollections }
            .flatMapLatest { [unowned i = indicator] room -> Single< [Fantasy.Card] > in
                
                guard room.settings.sharedCollections.count > 0 else { return .just([]) }
                    
                return Fantasy.Manager.fetchSwipesDeck(in: room)
                    .trackView(viewIndicator: i)
                    .map { $0.cards ?? [] }
                    .asSingle()
                    
                
            }
            .asDriver(onErrorJustReturn: [])
            
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

typealias CollectionPicked = (Fantasy.Collection) -> Void
class FantasyDeckViewModel : MVVM_ViewModel {

    typealias PresentationStyle = FantasyDeckViewController.PresentationStyle
    
    let presentationStyle: PresentationStyle
    let provider: FantasyDeckProvier
    let room: SharedRoomResource?

    let emptyPeerPressed = BehaviorRelay<Bool>(value: false)
    let collectionPickedAction: CollectionPicked?
    
    fileprivate let cardTrigger = BehaviorRelay<Fantasy.Card?>(value: nil)
    fileprivate let collections = BehaviorRelay<[Fantasy.Collection]>(value: [])
    fileprivate var viewTillOpenCardTimer = TimeSpentCounter()
    
    init(router: FantasyDeckRouter,
         provider: FantasyDeckProvier = MainDeckProvider(),
         presentationStyle: PresentationStyle  = .stack,
         room: SharedRoomResource? = nil,
         collectionFilter: Set<String> = [],
         container: UIViewController? = nil,
         collectionPickedAction: CollectionPicked? = nil) {
        self.router = router
        self.provider = provider
        self.presentationStyle = presentationStyle
        self.room = room
        self.collectionPickedAction = collectionPickedAction
        
        indicator.asDriver()
            .drive(onNext: { [weak h = container] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)

        appState.changesOf { $0.currentUser?.fantasies.purchasedCollections }
            .notNil()
            .asObservable()
            .flatMapLatest { _ -> Single<[Fantasy.Collection]> in
                return Fantasy.Manager.fetchCollections()
            }
            .map { $0.filter { collectionFilter.contains($0.id) == false } }
            .silentCatch(handler: router.owner)
            .bind(to: collections)
            .disposed(by: bag)
        
        self.buo = room?.value.shareLine()
        
        // Check likes cars count to display Review popup
        SettingsStore.likedCardsCount.observable
            .filter { $0.isEmpty == false }
            .map { (SettingsStore.currentUser.value?.id, $0) }
            .filter { $0.1.isEmpty == false && $0.0 != nil }
            .filter { [12, 36, 84].contains($0.1[$0.0!]) }
            .asObservable()
            .subscribe(onNext: { (count) in
                SKStoreReviewController.requestReview()
            })
            .disposed(by: bag)
    }
    
    let router: FantasyDeckRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
 
    private var buo: BranchUniversalObject!
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
    
    func cardTapped(card: Fantasy.Card) {
        
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
        
        if let x = collectionPickedAction, collection.isAvailable {
            return x(collection)
        }
        
        router.show(collection: collection, collectionPickedAction: collectionPickedAction)
    }
    
    func cardShown(card: Fantasy.Card) {
        viewTillOpenCardTimer.start()
    }
    
    func share(card: Fantasy.Card) {
        Fantasy.Request.ShareCard(id: card.id).rx.request
            .subscribe(onSuccess: { response in
                self.shareURL(response.url, card: card)
            })
            .disposed(by: bag)
    }
    
    func addCollection() {
        
        let room = self.room!
        
        router.showAddCollection(skip: Set(room.value.settings.sharedCollections)) { [unowned r = room, weak o = router.owner, unowned i = indicator] (collection) in
            
            var x = r.value
            x.settings.sharedCollections.insert(collection.id, at: 0)
            
            let _ =
            UpdateRoomSharedCollectionsResource(room: x).rx.request
                .trackView(viewIndicator: i)
                .silentCatch(handler: o)
                .subscribe { (_) in
                    r.accept(x)
                    Dispatcher.dispatch(action: UpdateRoom(room: x))
                }
            
        }
        
    }
    
    private func shareURL(_ url: String, card: Fantasy.Card) {
        guard let urlToShare = URL(string: url) else { return }
        
        let textToShare = card.text
        let objectsToShare = [textToShare, urlToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, isShared, _, _ in
            guard isShared else { return }
            
            Analytics.report(Analytics.Event.CardShared(card: card, context: self.provider.navigationContext))
        }
        router.owner.present(activityVC, animated: true, completion: nil)
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

        presentUser(id: r.value.me.id)
    }

    func presentPeer() {
        guard let r = room else { return }

        if let x = r.value.peer.userSlice?.id {
            presentUser(id: x)
            return;
        }
        
        emptyPeerPressed.accept(true)
        router.showInviteSheet(room: r)
        
    }

   private func presentUser(id: String) {
        UserManager.getUserProfile(id: id)
        .silentCatch(handler: router.owner)
        .subscribe(onNext: { user in
            self.router.showUser(user: user)
        })
        .disposed(by: bag)
    }
}
