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
    
    @IBOutlet weak var profileAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet private weak var label: UILabel!
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.name
            .drive(nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.image
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0)  }
            .map { $0 ?? R.image.noPhoto() }
            .drive(profileAvatarImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension UserGatewayViewController {
    
    @IBAction func teleport(_ sender: Any) {
        viewModel.teleport()
    }
    
}
