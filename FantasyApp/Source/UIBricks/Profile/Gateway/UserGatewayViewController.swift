//
//  UserGatewayViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import SafariServices
import StoreKit

class UserGatewayViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: UserGatewayViewModel! = .init(router: .init(owner: self))
    
    @IBOutlet weak var profileAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membershipTitle: UILabel!
    @IBOutlet weak var membershipSubtitle: UILabel!
    
    @IBOutlet weak var actionsContainer: UIView! {
        didSet {
            actionsContainer.layer.cornerRadius = 15
            actionsContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.isPremium
            .drive(onNext: { [weak v = view] (isSubscribed) in
                
                if let l = v?.layer.sublayers?.first as? CAGradientLayer {
                    l.removeFromSuperlayer()
                }
                
                isSubscribed ?
                    v?.addFantasySubscriptionGradient() :
                    v?.addFantasyTripleGradient()
                
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.name
            .drive(nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.image
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0)  }
            .map { $0 ?? R.image.noPhoto() }
            .drive(profileAvatarImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        viewModel.isPremium
            .map { $0 ? "Membership" : "Get Membership" }
            .drive(membershipTitle.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.isPremium
            .map { $0 ? "Manage Club Membership" : "Unlimited Rooms To Play, x3 New Fantasies Daily, ScreenProtect and more" }
            .drive(membershipSubtitle.rx.text)
            .disposed(by: rx.disposeBag)
        
    }
    
    override var prefersNavigationBarHidden: Bool {
        return true
    }

}

extension UserGatewayViewController {
    
    @IBAction func teleport(_ sender: Any) {
        viewModel.teleport()
    }
    
    @IBAction func tapFeedback(_ sender: Any) {
        
        let vc = SFSafariViewController(url: URL(string:"http://feedback.fantasyapp.com/")!)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
        
    }

    @IBAction func tapZendesk(_ sender: Any) {
        viewModel.help()
    }
    
    @IBAction func rateUs(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
    
}


