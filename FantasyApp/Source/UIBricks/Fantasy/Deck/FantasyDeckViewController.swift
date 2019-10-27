//
//  FantasyDeckViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Koloda
import RxSwift
import RxCocoa
import SnapKit

class FantasyDeckViewController: UIViewController, MVVM_View {

    private var animator = FantasyDetailsTransitionAnimator()

    lazy var viewModel: FantasyDeckViewModel! = .init(router: .init(owner: self))

    override var prefersNavigationBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var mutualCardContainer: UIView! {
        didSet {
            mutualCardContainer.alpha = 0
        }
    }
    @IBOutlet weak var tinyCardImageView: UIImageView!
    
    @IBOutlet weak var fanatasiesView: KolodaView! {
        didSet {
            fanatasiesView.dataSource = self
            fanatasiesView.countOfVisibleCards = 3
            fanatasiesView.delegate = self
            fanatasiesView.backgroundCardsTopMargin = 0
        }
    }
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    ///TODO: refactor to RxColodaDatasource
    private var cardsProxy: [Fantasy.Card] = []
    //private var selectedCardView:
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        viewModel.mode
            .drive(onNext: { [unowned self] mode in
                self.waitingView.isHidden = mode == .swipeCards
                self.fanatasiesView.isHidden = mode == .waiting
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.timeLeftText
            .drive(timeLeftLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.cards
            .drive(onNext: { [unowned self] (newState) in
                
                let from = self.fanatasiesView.currentCardIndex
                let internalState = self.cardsProxy.suffix(from: from)
                
                guard internalState.count == newState.count else {
                    self.cardsProxy = newState
                    self.fanatasiesView.resetCurrentCardIndex()
                    return
                }
                
                for (new, old) in zip(newState, internalState) where new != old {
                    
                    self.cardsProxy = newState
                    self.fanatasiesView.resetCurrentCardIndex()
                    return
                     
                }
                
            })
            .disposed(by: rx.disposeBag)

        viewModel.mutualCardTrigger
            .drive(onNext: { [unowned self] (x) in
                
                let url = x.imageURL
                
                ImageRetreiver.imageForURLWithoutProgress(url: url)
                    .drive(self.tinyCardImageView.rx.image)
                    .disposed(by: self.tinyCardImageView.rx.disposeBag)
                
                UIView.animate(withDuration: 0.5) {
                    self.mutualCardContainer.alpha = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        UIView.animate(withDuration: 0.5) {
                            self.mutualCardContainer.alpha = 0
                        }
                    }
                }
                
            })
            .disposed(by: rx.disposeBag)

        view.addFantasyGradient()
    }
    
}

private extension FantasyDeckViewController {
    
    @IBAction func searchTapped(_ sender: Any) {
        viewModel.searchTapped()
    }
    
}

extension FantasyDeckViewController: KolodaViewDataSource, KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = cardsProxy[index]
        let view = FantasyDeckItemView(frame: koloda.bounds)
        view.hasStory = !card.text.isEmpty
        view.isPaid = card.isPaid
        view.imageURL = card.imageURL
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return cardsProxy.count
    }
 
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if case .left = direction {
            viewModel.swiped(card: cardsProxy[index], direction: .left)
        } else if case .right = direction {
            viewModel.swiped(card: cardsProxy[index], direction: .right)
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let card = cardsProxy[index]
        viewModel.cardTapped(card: card)
    }
    
}

extension FantasyDeckViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let deckFrame = fanatasiesView.superview?.convert(fanatasiesView.frame, to: nil) else {
            return animator
        }

        let ratio = fanatasiesView.frame.height / FantasyDetailsViewController.minBackgroundImageHeight
        let originFrame = CGRect(x: (UIScreen.main.bounds.width - (UIScreen.main.bounds.width * ratio)) / 2.0,
                                 y: (UIScreen.main.bounds.height - (UIScreen.main.bounds.height * ratio)) / 2.0,
                                 width: UIScreen.main.bounds.width * ratio,
                                 height: UIScreen.main.bounds.height * ratio)

        animator.originFrame = originFrame
        animator.presenting = true
        
        return animator
    }
}
