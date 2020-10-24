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

    @IBOutlet private weak var signinButton: UIButton! {
        didSet {
            signinButton.setTitle(R.string.localizable.loginSignInButton(), for: .normal)
        }
    }
    @IBOutlet private weak var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = R.string.localizable.loginEmailPlaceholder()
        }
    }
    @IBOutlet private weak var passwordTextField: UITextField! {
           didSet {
               passwordTextField.placeholder = R.string.localizable.loginPasswordPlaceholder()
           }
       }
    @IBOutlet var buttonToKeyboardConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeTitleLabel: UILabel! {
        didSet {
            welcomeTitleLabel.text = R.string.localizable.loginWelcomeBack()
        }
    }
    
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            signupButton.setTitle(R.string.localizable.loginSignUpButton(), for: .normal)
        }
    }
    
    @IBOutlet weak var forgotPasswordButton: UIButton! {
         didSet {
             forgotPasswordButton.setTitle(R.string.localizable.loginForgotPassword(), for: .normal)
         }
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            emailTextField.text = "pete1@jackson.com"
            passwordTextField.text = "1234"
        #else 
        #endif

        #if ADHOC || RELEASE
        viewModel.signinButtonEnabled
            .drive(signinButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        #endif
        
        emailTextField.rx.text
            .skip(1)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.emailChanged(email: x ?? "")
            })
            .disposed(by: rx.disposeBag)

        ///password

        passwordTextField.rx.text
            .skip(1)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.passwordChanged(password: x ?? "")
            })
            .disposed(by: rx.disposeBag)

        // keyboard control

        let mapper: (Notification) -> (CGFloat, CGFloat) = { n -> (CGFloat, CGFloat) in
            let to = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.origin.y
            let from = (n.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.origin.y

            let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! CGFloat

            return (duration, from - to)
        }

        let show = NotificationCenter.default
            .rx.notification( UIResponder.keyboardWillShowNotification )
            .map(mapper)

        let hide = NotificationCenter.default
            .rx.notification( UIResponder.keyboardWillHideNotification )
            .map(mapper)

        Observable.of(show, hide)
            .merge()
            .subscribe(onNext: { [unowned self] (duration, delta) in
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    self.buttonToKeyboardConstraint.constant += delta
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

extension LoginViewController {

    @IBAction func register(_ sender: Any) {
        viewModel.presentRegister()
    }
        
    @IBAction func signIn(_ sender: Any) {
        viewModel.login(email: emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? "",
                        password: passwordTextField.text ?? "")
    }
    
    @IBAction func closeSignIn(_ sender: Any) {
        viewModel.closeSignIn()
    }

    @IBAction func forgotPassword(_ sender: Any) {
        viewModel.presentForgotPassword()
    }
}
