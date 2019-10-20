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

    @IBOutlet private weak var signinButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet var buttonToKeybosrdConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "pete1@jackson.com"
        passwordTextField.text = "1234"


        viewModel.signinButtonEnabled
            .drive(signinButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

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
                    self.buttonToKeybosrdConstraint.constant += delta
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
