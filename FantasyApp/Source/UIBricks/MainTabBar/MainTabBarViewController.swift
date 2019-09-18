//
//  MainTabBarViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MainTabBarViewController: UITabBarController, MVVM_View {
    
    var viewModel: MainTabBarViewModel!
    
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
//        viewModel.locationRequestHidden
//            .drive(onNext: { [unowned self] (hidden) in
//                
//                if hidden {
//                    if self.presentedViewController != nil {
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                }
//                else {
//                    let vc = R.storyboard.main.locationRequestViewController()!
//                    self.present(vc, animated: true, completion: nil)
//                }
//                
//            })
//            .disposed(by: rx.disposeBag)
        
    }
    
}

private extension MainTabBarViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
