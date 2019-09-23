//
//  FantasyDetailsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class FantasyDetailsViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyDetailsViewModel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
     
        viewModel.likeText
            .drive(likeButton.rx.title(for: .normal))
            .disposed(by: rx.disposeBag)
        
    }
    

    
}

private extension FantasyDetailsViewController {
    
    @IBAction func likeAction(_ sender: Any) {
        viewModel.likeButtonTapped()
    }
    
}
