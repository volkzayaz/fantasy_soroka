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
    
    lazy var viewModel: FantasyDeckViewModel! = .init(router: .init(owner: self))
    
    @IBOutlet weak var fanatasiesView: KolodaView! {
        didSet {
            fanatasiesView.dataSource = self
            fanatasiesView.countOfVisibleCards = 3
            fanatasiesView.delegate = self
        }
    }
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    ///TODO: refactor to RxColodaDatasource
    private var cardsProxy: [Fantasy.Card] = []
    
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
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let view = UIView()
        view.backgroundColor = index % 2 == 0 ? .blue : .green

        let card = cardsProxy[index]
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        ImageRetreiver.imageForURLWithoutProgress(url: card.imageURL)
            .drive(imageView.rx.image)
            .disposed(by: imageView.rx.disposeBag)
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = card.text
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        
        view.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
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
