//
//  MyFantasiesReactionHistoryViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MyFantasiesReactionHistoryViewController: UIViewController, MVVM_View {
    
    var viewModel: MyFantasiesReactionHistoryViewModel!

    @IBOutlet weak var likedButton: PrimaryButton! {
        didSet {
            likedButton.mode = .selector
            likedButton.titleFont = .mediumFont(ofSize: 15)
        }
    }
    @IBOutlet weak var dislikedButton: PrimaryButton! {
        didSet {
            dislikedButton.mode = .selector
            dislikedButton.titleFont = .mediumFont(ofSize: 15)
        }
    }

    fileprivate let state = BehaviorRelay<Int>(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addFantasyGradient()
    }
}

//MARK:- Actions

extension MyFantasiesReactionHistoryViewController {

    @IBAction func likedAction(_ sender: Any) {
        likedButton.isSelected = true
        dislikedButton.isSelected = false
        state.accept(0)
    }

    @IBAction func dislikedAction(_ sender: Any) {
        likedButton.isSelected = false
        dislikedButton.isSelected = true
        state.accept(1)

    }

}

extension MyFantasiesReactionHistoryViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.myFantasiesReactionHistoryViewController.embedFantasyList.identifier {

            let provider: Driver<[Fantasy.Card]> = state.asObservable().flatMapLatest { (x) -> Single<[Fantasy.Card]> in
                
                if x == 0 {
                    return Fantasy.Request.FetchCards(reactionType: .liked).rx.request
                }
                
                return Fantasy.Request.FetchCards(reactionType: .disliked).rx.request
            }
            .asDriver(onErrorJustReturn: Array<Fantasy.Card>())

            let stateVar = state.value

            let vc = segue.destination as! FantasyListViewController
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: provider,
                                                detailsProvider: { card in
                                                    OwnFantasyDetailsProvider(card: card,
                                                                              initialReaction: stateVar == 0 ? .like : .dislike)
                                                })
        }
        
    }

}
