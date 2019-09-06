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

class UserGatewayViewController: UIViewController, MVVM_View {
    
    lazy var viewModel: UserGatewayViewModel! = .init(router: .init(owner: self))
    
    @IBOutlet private weak var tempLocationLabel: UILabel!
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet private weak var label: UILabel!
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tempLocation
            .drive(tempLocationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
    }
    
}

private extension UserGatewayViewController {

    @IBAction func logout(_ sender: Any) {
        viewModel.logout()
    }
    
    @IBAction func dislikedCardsTapped(_ sender: Any) {
        viewModel.showDislikedCards()
    }
    
    @IBAction func likedCardsTapped(_ sender: Any) {
        viewModel.showLikedCards()
    }

    @IBAction func editProfile(_ sender: Any) {
        viewModel.showEditProfile()
    }
}
