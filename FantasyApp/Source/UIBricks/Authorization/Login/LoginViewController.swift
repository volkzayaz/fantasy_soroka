//
//  LoginViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class LoginViewController: UIViewController, MVVM_View {
    
    var viewModel: LoginViewModel!
    
    @IBOutlet private weak var loginView: UIView!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

private extension LoginViewController {

    @IBAction func register(_ sender: Any) {
        viewModel.presentRegister()
    }
    
    @IBAction func facebookSignIn(_ sender: Any) {
        viewModel.authorizeUsingFacebook()
    }
        
    @IBAction func signIn(_ sender: Any) {
        viewModel.login(email: emailTextField.text ?? "",
                        password: passwordTextField.text ?? "")
    }

    @IBAction func presentSignIn(_ sender: Any) {
        loginView.transform = CGAffineTransform(translationX: 0, y: view.frame.size.height)
        loginView.alpha = 0
        loginView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,
                       options: [.curveEaseOut], animations: {
                        self.loginView.transform = .identity
                        self.loginView.alpha = 1
                        
        }, completion: { _ in })
    }
    
    @IBAction func closeSignIn(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, delay: 0,
                       options: [.curveEaseOut], animations: {
                        self.loginView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
                        self.loginView.alpha = 0
        }, completion: { _ in
            self.loginView.transform = .identity
            self.loginView.isHidden = true
        })
        
    }
    
}
