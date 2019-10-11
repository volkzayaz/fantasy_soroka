//
//  RootViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RootViewController: UINavigationController, MVVM_View {
    
    lazy var viewModel: RootViewModel! = .init(router: .init(owner: self))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.state
            .drive(onNext: { [unowned self] (x) in
                
                switch x {
                    
                case .mainApp:
                    let vc = R.storyboard.main.mainTabBarViewController()!
                    vc.viewModel = .init(router: .init(owner: vc))
                    vc.selectedIndex = 1
                    self.setViewControllers([vc], animated: true)
                    
                case .authentication:
                    let vc = R.storyboard.authorization.loginViewController()!
                    vc.viewModel = .init(router: .init(owner: vc))
                    self.setViewControllers([vc], animated: true)
                    
                case .ageRestriction:
                    let vc = R.storyboard.authorization.ageRestrictionViewConrtoller()!
                    self.setViewControllers([vc], animated: true)
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        
        
    }
    
}

private extension RootViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
