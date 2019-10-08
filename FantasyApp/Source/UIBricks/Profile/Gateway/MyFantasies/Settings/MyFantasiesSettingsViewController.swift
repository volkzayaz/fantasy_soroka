//
//  MyFantasiesSettingsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MyFantasiesSettingsViewController: UIViewController, MVVM_View {
    
    var viewModel: MyFantasiesSettingsViewModel!
    
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

extension MyFantasiesSettingsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.myFantasiesSettingsViewController.blockedFantasiesSegue.identifier {
            
            let vc = segue.destination as! FantasyListViewController
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: Fantasy.Request.ReactionCards(reactionType: .blocked).rx.request.asDriver(onErrorJustReturn: []))
        }
            
    }
    
}
