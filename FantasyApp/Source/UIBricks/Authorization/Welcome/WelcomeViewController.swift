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

    @IBOutlet private weak var termsTextView: UITextView! {
        didSet {
            let text = R.string.localizable.authWelcomeTermsText(R.string.localizable.authTerms(), R.string.localizable.authPrivacy(), R.string.localizable.authRules())
            let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.regularFont(ofSize: 12)])

            attr.addAttributes([
                .link : viewModel.termsUrl,
                .font: UIFont.boldFont(ofSize: 12)],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authTerms())!))

            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .font: UIFont.boldFont(ofSize: 12)],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authPrivacy())!))

            attr.addAttributes([
                .link : viewModel.communityRulesUrl,
                .font: UIFont.boldFont(ofSize: 12)],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authRules())!))

            termsTextView.attributedText = attr
            termsTextView.textColor = .white
            termsTextView.tintColor = .white
            termsTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            termsTextView.backgroundColor = .clear
            termsTextView.textAlignment = .center
        }
    }

}

// MAKR:- Actions

extension WelcomeViewController {

    @IBAction func register(_ sender: Any) {
        viewModel.presentRegister()
    }

    @IBAction func facebookSignIn(_ sender: Any) {
        viewModel.authorizeUsingFacebook()
    }

    @IBAction func presentSignIn() {
        viewModel.presentSignIn()
    }
}

//MARK:- UITextViewDelegate

extension WelcomeViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        guard UIApplication.shared.canOpenURL(URL) else { return false }

        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }

}
