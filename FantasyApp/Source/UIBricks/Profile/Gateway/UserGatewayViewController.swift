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

class UserGatewayViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: UserGatewayViewModel! = .init(router: .init(owner: self))
    
    @IBOutlet weak var profileAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscriptionSuggestionImageView: UIImageView!
    
    @IBOutlet weak var actionsContainer: UIView! {
        didSet {
            actionsContainer.layer.cornerRadius = 15
            actionsContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        
        viewModel.name
            .drive(nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.image
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0)  }
            .map { $0 ?? R.image.noPhoto() }
            .drive(profileAvatarImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        viewModel.isPremium
            .drive(subscriptionSuggestionImageView.rx.isHidden)
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
    
}
