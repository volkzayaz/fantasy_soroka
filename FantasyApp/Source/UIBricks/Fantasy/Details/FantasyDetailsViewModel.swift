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
    
}

struct FantasyDetailsViewModel: MVVM_ViewModel {

    private let provider: FantasyDetailProvider
    private var timeSpentCounter = TimeSpentCounter()
    private var collapsedStory = false
    
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
    
    func likeCard() {
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
    }

    func dislikeCard() {
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
    }

    func close() {
        router.close()
    }
    
    func show(collection: Fantasy.Collection) {
        router.show(collection: collection, context: .Card(provider.navigationContext))
    }
 
    mutating func viewAppeared() {
        timeSpentCounter.start()
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
    
}
