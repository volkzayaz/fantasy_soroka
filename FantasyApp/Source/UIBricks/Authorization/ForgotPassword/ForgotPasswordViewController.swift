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

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var resetPasswordButton: UIButton!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var codeWasSentView: UIView!
    @IBOutlet private weak var wrongEmailView: UIView!

    @IBOutlet var buttonToKeyboardConstraint: NSLayoutConstraint! // 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.showWrongEmail
            .map { !$0 }
            .drive(wrongEmailView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showCodeWasSent
            .map { !$0 }
            .drive(codeWasSentView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.loading
            .map { !$0 }
            .drive(loadingView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.resetButtonEnabled
            .drive(resetPasswordButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        emailTextField.rx.text
            .skip(1)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.emailChanged(email: x ?? "")
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

        let constraintBaseVal = self.buttonToKeyboardConstraint.constant

        Observable.of(show, hide)
            .merge()
            .subscribe(onNext: { [unowned self] (duration, delta) in
                UIView.animate(withDuration: TimeInterval(duration), animations: {

                    var val = self.buttonToKeyboardConstraint.constant
                    val += delta

                    self.buttonToKeyboardConstraint.constant = val >= constraintBaseVal ? val : constraintBaseVal
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
    }
    
}

extension ForgotPasswordViewController {

    @IBAction func closeSignIn(_ sender: Any) {
        emailTextField.resignFirstResponder()
        viewModel.closeSignIn()
    }

    @IBAction func resetPassword(_ sender: Any) {

        guard let t = emailTextField.text else { return }

        emailTextField.resignFirstResponder()
        viewModel.resetPassword(t)
    }

    @IBAction func tap(_ sender: Any) {
        viewModel.closeSignIn()
    }
}
