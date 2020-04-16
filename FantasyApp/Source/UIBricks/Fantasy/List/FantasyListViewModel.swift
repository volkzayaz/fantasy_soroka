//
//  FantasyListViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension FantasyListViewModel {

    var dataSource: Driver<[AnimatableSectionModel<String, CardType>]> {
        
        return Driver.combineLatest(
            protectPolicy,
            provider,
            Fantasy.Request.FetchCards(reactionType: .liked).rx.request.asDriver(onErrorJustReturn: []),
            Fantasy.Request.FetchCards(reactionType: .disliked).rx.request.asDriver(onErrorJustReturn: [])
        )
        .map { isSubscribed, cards, myLiked, myDisliked in
            
            guard cards.count > 0 else {
                return [AnimatableSectionModel(model: "", items: [.empty(0),.empty(1),.empty(2),.empty(3)])]
            }
            
            return [AnimatableSectionModel(model: "",
                                           items:
                 cards.map { card in
                    
                    let liked = myLiked.contains { $0.id == card.id }
                    let disliked = myDisliked.contains { $0.id == card.id }
                    
                    return .fantasy(ProtectedEntity(entity: card,
                                             isProtected: isSubscribed),
                             liked || disliked
                    )
            })
                
            ]
            
        }
        
    }
    
    var tableScrollEnabled: Driver<Bool> {
        return dataSource.map { x in
            if case .empty(_)? = x.first?.items.first {
                return false
            }
             
            return true
        }
    }

    var cardTitle: Driver<NSAttributedString> {
        return dataSource.map { x -> NSAttributedString? in
            guard var count = x.first?.items.count else {
                return nil
            }
            
            if case .empty(_)? = x.first?.items.first {
                count = 0
            }
                
            return self.titleProvider(count)
        }
        .notNil()
    }
    
    enum CardType: IdentifiableType, Equatable {
        case fantasy(ProtectedEntity<Fantasy.Card>, Bool)
        case empty(Int)
        
        var identity: String {
            switch self {
            case .fantasy(let c, _): return c.entity.identity
            case .empty(let x): return "\(x)"
            }
        }
    }
    
}

typealias FantasyListTitleProvider = (Int) -> NSAttributedString

struct FantasyListViewModel : MVVM_ViewModel {
    
    fileprivate let provider: Driver<[Fantasy.Card]>
    fileprivate let protectPolicy: Driver<Bool>
    fileprivate let detailsProvider: (Fantasy.Card) -> FantasyDetailProvider
    
    let titleProvider: FantasyListTitleProvider
    
    let animator = FantasyDetailsTransitionAnimator()
    
    init(router: FantasyListRouter,
         cardsProvider: Driver<[Fantasy.Card]>,
         detailsProvider: @escaping (Fantasy.Card) -> FantasyDetailProvider,
         titleProvider: @escaping FantasyListTitleProvider = FantasyListViewModel.countTitleProvider,
         protectPolicy: Driver<Bool> = .just(false)) {
        self.router = router
        self.provider = cardsProvider
        self.detailsProvider = detailsProvider
        self.protectPolicy = protectPolicy
        self.titleProvider = titleProvider

        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: FantasyListRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
    static var countTitleProvider: FantasyListTitleProvider {
        return { (count) -> NSAttributedString in
            
            let text: String
            if count == 0 {
                text = "Swipe to see\nnew Fantasies!"
            }
            else if count == 1 {
                text = "1 " + R.string.localizable.fantasyDeckCardsCountOne()
            }
            else {
                text = "\(count) " + R.string.localizable.fantasyDeckCardsCountSeveral()
            }
            
            let att = NSMutableAttributedString(string: text, attributes: [.font: UIFont.boldFont(ofSize: 25)])
            
            if let range = text.range(of: "\(count)") {
                att.addAttributes([.foregroundColor : R.color.textPinkColor()!],
                                  range: text.nsRange(from: range))
            }
            
            return att
        }
    }
    
}

extension FantasyListViewModel {
    func cardTapped(card: Fantasy.Card, sourceFrame: CGRect) {
        animator.originFrame = sourceFrame
        
        router.cardTapped(provider: detailsProvider(card) )
    }
}
