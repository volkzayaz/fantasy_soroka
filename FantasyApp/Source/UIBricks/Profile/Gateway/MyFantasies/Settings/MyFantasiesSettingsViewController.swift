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

    @IBOutlet weak var collectionImageView: UIImageView! {
        didSet {
            collectionImageView.layer.cornerRadius = 5.0
        }
    }

    @IBOutlet weak var scrollView: UIScrollView! {
           didSet {
               scrollView.addFantasyRoundedCorners()
               scrollView.backgroundColor = R.color.listBackgroundColor()
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addFantasyGradient()
    }

        @IBAction func collectionTap(_ sender: Any) {

        }
}
