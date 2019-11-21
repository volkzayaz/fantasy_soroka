//
//  MyFantasiesViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MyFantasiesViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: MyFantasiesViewModel! = MyFantasiesViewModel(router: .init(owner: self))
    
    @IBOutlet weak var cardsButton: PrimaryButton! {
        didSet {
            cardsButton.mode = .selector
            cardsButton.titleFont = .mediumFont(ofSize: 15)
        }
    }
    @IBOutlet weak var collectionButton: PrimaryButton! {
        didSet {
            collectionButton.mode = .selector
            collectionButton.titleFont = .mediumFont(ofSize: 15)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         *  Set up any bindings here
         *  viewModel.labelText
         *     .drive(label.rx.text)
         *     .addDisposableTo(rx_disposeBag)
         */

        view.addFantasyGradient()
        
    }
    
}

//MARK:- Actions

extension MyFantasiesViewController {

    @IBAction func cardsAction(_ sender: Any) {
        cardsButton.isSelected = true
        collectionButton.isSelected = false

//        viewModel.sourceChanged(source: .incomming )
    }

    @IBAction func collectionAction(_ sender: Any) {
        cardsButton.isSelected = false
        collectionButton.isSelected = true

//        viewModel.sourceChanged(source: .outgoing )
    }

}

//MARK:- Navigation

extension MyFantasiesViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.myFantasiesViewController.embedLikedCards.identifier {
            
            let vc = segue.destination as! FantasyListViewController
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: Fantasy.Request.FetchCards(reactionType: .liked).rx.request.asDriver(onErrorJustReturn: []),
                                                detailsProvider: { card in
                                                    OwnFantasyDetailsProvider(card: card,
                                                                              initialReaction: .like)
            },
                                                title: "")
            
        }
        
    }
    
}
