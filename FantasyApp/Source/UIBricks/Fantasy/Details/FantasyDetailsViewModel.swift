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
import RxDataSources
import Branch

extension FantasyDetailsViewModel {
    
    var description: String { return provider.card.story }
    var dislikesCount: Int { return provider.card.dislikes }
    var likesCount: Int { return provider.card.likes }
    var imageURL: String { return provider.card.imageURL }

    var collectionsDataSource: Driver<[AnimatableSectionModel<String, Fantasy.Collection>]> {
        return Fantasy.Manager.fetchCollections()
            .silentCatch(handler: router.owner)
            .asDriver(onErrorJustReturn: [])
            .map { collections in
                return [AnimatableSectionModel(model: "", items: collections.filter { !$0.isPurchased })]
        }
    }

    var preferenceEnabled: Bool {
        return provider.preferenceEnabled
    }
    
}

struct FantasyDetailsViewModel: MVVM_ViewModel {

    private let provider: FantasyDetailProvider
    private var timeSpentCounter = TimeSpentCounter()
    private var collapsedStory = false
    private var viewTillFirstReactionTimer = TimeSpentCounter()
    
    let currentState: BehaviorRelay<Fantasy.Card.Reaction>
    
    init(router: FantasyDetailsRouter, provider: FantasyDetailProvider) {
        self.router = router
        self.provider = provider
        self.currentState = BehaviorRelay(value: provider.initialReaction)
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyDetailsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    private var buo: BranchUniversalObject!
    
    struct CellModel: IdentifiableType, Equatable {
        var identity: String {
            return uid
        }

        let uid: String
        let isPaid: Bool
        let title: String
        let cardsCount: Int
        let imageURL: String
        
        let collection: Fantasy.Collection
    }
    
}

extension FantasyDetailsViewModel {
    
    mutating func likeCard() {
        var reaction = currentState.value
        
        switch currentState.value {
        case .like:              reaction = .neutral
        case .neutral, .dislike: reaction = .like
        case .block:             return;
        }
        
        guard provider.shouldReact(to: reaction) else {
            return
        }

        currentState.accept(reaction)
        
        reportReactionTime(reaction: .like)
    }

    mutating func dislikeCard() {
        
        var reaction = currentState.value

        switch currentState.value {
        case .dislike:           reaction = .neutral
        case .neutral, .like:    reaction = .dislike
        case .block:             return;
        }

        guard provider.shouldReact(to: reaction) else {
            return
        }
        
        currentState.accept(reaction)
        
        reportReactionTime(reaction: .dislike)
    }
    
    mutating func blockCard() {
        let reaction = Fantasy.Card.Reaction.block

        guard provider.shouldReact(to: reaction) else {
            return
        }
        
        currentState.accept(reaction)
        
        reportReactionTime(reaction: .block)
    }

    func close() {
        router.close()
    }
    
    func show(collection: Fantasy.Collection) {
        router.show(collection: collection, context: .Card(provider.navigationContext))
    }
 
    mutating func viewAppeared() {
        timeSpentCounter.start()
        viewTillFirstReactionTimer.start()
    }
    
    mutating func viewWillDisappear() {
        
        Analytics.report( Analytics.Event.CardViewed(card: provider.card,
                                                     context: provider.navigationContext,
                                                     collapsedContent: collapsedStory,
                                                     spentTime: timeSpentCounter.finish()) )
        
    }
    
    mutating func expandStory() {
        collapsedStory = true
    }
    
    func share() {
        Fantasy.Request.ShareCard(id: provider.card.id).rx.request
            .subscribe(onSuccess: { response in
                self.shareURL(response.url, card: self.provider.card)
            })
            .disposed(by: bag)
    }
    
    private func shareURL(_ url: String, card: Fantasy.Card) {
        guard let urlToShare = URL(string: url) else { return }
        
        let textToShare = R.string.localizable.branchObjectCardShareDescription()
        let objectsToShare = [textToShare, urlToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, isShared, _, _ in
            guard isShared else { return }
            
            Analytics.report(Analytics.Event.CardShared(card: card, context: self.provider.navigationContext))
        }
        router.owner.present(activityVC, animated: true, completion: nil)
    }
    
    private mutating func reportReactionTime(reaction: Fantasy.Card.Reaction) {
        
        ///we are interested only in initial reaction time
        guard provider.initialReaction == .neutral else { return }
        
        Analytics.report(Analytics.Event.CardReactionTime(card: provider.card,
                                                          context: provider.navigationContext,
                                                          spentTime: viewTillFirstReactionTimer.finish(),
                                                          reaction: reaction))
        
    }
    
}
