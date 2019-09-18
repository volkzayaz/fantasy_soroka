//
//  DiscoveryFilterViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class DiscoveryFilterViewController: UIViewController, MVVM_View {
    
    var viewModel: DiscoveryFilterViewModel!
    
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

private extension DiscoveryFilterViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
