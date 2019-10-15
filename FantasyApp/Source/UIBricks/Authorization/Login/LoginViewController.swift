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

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "pete1@jackson.com"
        passwordTextField.text = "1234"
    }
    
}

extension LoginViewController {

    @IBAction func register(_ sender: Any) {
        viewModel.presentRegister()
    }
        
    @IBAction func signIn(_ sender: Any) {
        viewModel.login(email: emailTextField.text ?? "",
                        password: passwordTextField.text ?? "")
    }
    
    @IBAction func closeSignIn(_ sender: Any) {
        viewModel.closeSignIn()
    }

    @IBAction func forgotPassword(_ sender: Any) {
        viewModel.presentForgotPassword()
    }
}
