//
//  ForgotPasswordViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ForgotPasswordViewController: UIViewController, MVVM_View {
    
    var viewModel: ForgotPasswordViewModel!
    
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet weak var label: UILabel!
     */
    @IBOutlet private weak var emailTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         *  Set up any bindings here
         *  viewModel.labelText
         *     .drive(label.rx.text)
         *     .addDisposableTo(rx_disposeBag)
         */
        
    }
    
}

extension ForgotPasswordViewController {

    @IBAction func closeSignIn(_ sender: Any) {
        viewModel.closeSignIn()
    }

    @IBAction func resetPassword(_ sender: Any) {

        guard let t = emailTextField.text else { return }

        viewModel.resetPassword(t)
    }
}
