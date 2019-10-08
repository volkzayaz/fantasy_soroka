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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         *  Set up any bindings here
         *  viewModel.labelText
         *     .drive(label.rx.text)
         *     .addDisposableTo(rx_disposeBag)
         */
        
    }
    
}

extension MyFantasiesReactionHistoryViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.myFantasiesReactionHistoryViewController.embedFantasyList.identifier {
            
            let provider = segmentedControl.rx.value.flatMapLatest { x -> Single<[Fantasy.Card]> in
                
                if x == 0 {
                    return Fantasy.Request.ReactionCards(reactionType: .liked).rx.request
                }
                
                return Fantasy.Request.ReactionCards(reactionType: .disliked).rx.request
            }
            .asDriver(onErrorJustReturn: [])
            
            let vc = segue.destination as! FantasyListViewController
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: provider)
                
            
        }
        
    }

}
