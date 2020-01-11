//
//  SubscribeButton.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 11.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import UIKit

class SubscribeButton: UIButton {
    
    @IBOutlet unowned var presenter: UIViewController!
    var defaultPage = SubscriptionViewModel.Page.member
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        setBackgroundImage(R.image.subscribeButton(), for: .normal)
        setTitle(nil, for: .normal)
        
        addTarget(self, action: Selector("subscribe"), for: .touchUpInside)
        
        appState.map { $0.currentUser?.subscription.isSubscribed ?? false }
            .drive(rx.isHidden)
            .disposed(by: rx.disposeBag)
    }
    
    @objc func subscribe() {
        
        guard let x = presenter else {
            fatalErrorInDebug("You should set `subscribeButton.presenter = myViewController` before clicking the button")
            return
        }
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: defaultPage)
        
        x.present(nav, animated: true, completion: nil)
        
        
    }
    
}
