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
    
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet private weak var label: UILabel!
     */
    
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

extension MyFantasiesViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.myFantasiesViewController.embedLikedCards.identifier {
            
            let vc = segue.destination as! FantasyListViewController
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cards: User.current!.fantasies.liked)
            
        }
        
    }
    
    @IBAction func blockedCards(_ sender: Any) {
        viewModel.showBlockedCards()
    }
    
    @IBAction func dislikedCards(_ sender: Any) {
        viewModel.showDislikedCards()
    }
    
    @IBAction func likedCards(_ sender: Any) {
        viewModel.showLikedCards()
    }
    
}
