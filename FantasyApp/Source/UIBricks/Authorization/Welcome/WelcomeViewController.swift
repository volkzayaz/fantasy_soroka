//
//  WelcomeViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class WelcomeViewController: UIViewController, MVVM_View {
    
    var viewModel: WelcomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension WelcomeViewController {

    @IBAction func register(_ sender: Any) {
        viewModel.presentRegister()
    }

    @IBAction func facebookSignIn(_ sender: Any) {
        viewModel.authorizeUsingFacebook()
    }

}
