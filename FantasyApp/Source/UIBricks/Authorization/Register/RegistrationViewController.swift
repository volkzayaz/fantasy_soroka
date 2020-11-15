//
//  RegistrationViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RegistrationViewController: UIViewController, MVVM_View {

    var imagePicker: FantasyImagePickerController?    
    var viewModel: RegistrationViewModel!

    @IBOutlet private weak var delayedStepForwardButton: UIButton!
    @IBOutlet private weak var stepForwardButton: UIButton!
    @IBOutlet private var backwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet private var forwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    @IBOutlet private weak var onboarding1BackgroundRoundedView: UIView! {
        didSet {
            onboarding1BackgroundRoundedView.addFantasyRoundedCorners()
        }
    }
    
    @IBOutlet private weak var onboarding2BackgroundRoundedView: UIView! {
        didSet {
            onboarding2BackgroundRoundedView.addFantasyRoundedCorners()
        }
    }
    
    @IBOutlet private weak var onboarding3BackgroundRoundedView: UIView! {
        didSet {
            onboarding3BackgroundRoundedView.addFantasyRoundedCorners()
        }
    }
    
    // Notice section
    @IBOutlet private weak var agrementBackgroundRoundedView: UIView! {
        didSet {
            agrementBackgroundRoundedView.addFantasyRoundedCorners()
        }
    }
    
    @IBOutlet weak var agrementTitle: UILabel!
    @IBOutlet private weak var agrementTextView: UITextView! {
        didSet {
            agrementTextView.text = R.string.localizable.registrationNoticeAgreementText()
        }
    }

    @IBOutlet private weak var iveReadTermsTextView: UITextView! {
        didSet {
            let text = R.string.localizable.authRegisterIveReadTermsText(R.string.localizable.authTerms(), R.string.localizable.authPrivacy(), "Fantasy \(R.string.localizable.authRules())")

            let attr = NSMutableAttributedString(string: text,
             attributes: [
                .font: UIFont.regularFont(ofSize: 14),
                .foregroundColor: R.color.textBlackColor()!
            ])
            
            attr.addAttributes([
                .link : viewModel.termsUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authTerms())!))
            
            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authPrivacy())!))
            
            attr.addAttributes([
                .link : viewModel.communityRulesUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)],
                               range: text.nsRange(from: text.range(of: "Fantasy \(R.string.localizable.authRules())")!))

            iveReadTermsTextView.attributedText = attr
            iveReadTermsTextView.tintColor = R.color.textPinkColor()
            iveReadTermsTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @IBOutlet private weak var personalDataTextView: UITextView! {
        didSet {
            let text = R.string.localizable.authRegisterPersonalDataText(R.string.localizable.authTerms(), R.string.localizable.authPrivacy()) + R.string.localizable.authRegisterPersonalDataTextRemove()
            
            let attr = NSMutableAttributedString(string: text,
             attributes: [
                .font: UIFont.regularFont(ofSize: 14),
                .foregroundColor: R.color.textBlackColor()!
            ])
            
            attr.addAttributes([
                .link : viewModel.termsUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authTerms())!))
            
            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authPrivacy())!))
            
            attr.addAttributes([
                .foregroundColor: R.color.textLightGrayColor()!
            ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authRegisterPersonalDataTextRemove())!))

            personalDataTextView.attributedText = attr
            personalDataTextView.tintColor = R.color.textPinkColor()
            personalDataTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @IBOutlet private weak var sensetiveDataTextView: UITextView! {
        didSet {
            
            let text = R.string.localizable.authRegisterSensetiveData(R.string.localizable.authPrivacy()) + R.string.localizable.authRegisterSensetiveData1()
            
            let attr = NSMutableAttributedString(string: text,
             attributes: [
                .font: UIFont.regularFont(ofSize: 14),
                .foregroundColor: R.color.textBlackColor()!
            ])
            
            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authPrivacy())!))
            
            attr.addAttributes([
                .foregroundColor: R.color.textLightGrayColor()!
            ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authRegisterSensetiveData1())!))
            
            sensetiveDataTextView.attributedText = attr
            sensetiveDataTextView.tintColor = R.color.textPinkColor()
            sensetiveDataTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

    }
        
    @IBOutlet private weak var agreeToEmailsTextView: UITextView! {
        didSet {
            let text = R.string.localizable.authRegisterAgreeToEmails(R.string.localizable.authTerms(), R.string.localizable.authPrivacy()) + R.string.localizable.authRegisterAgreeToEmailsUnsubscribe()
            
            let attr = NSMutableAttributedString(string: text,
             attributes: [
                .font: UIFont.regularFont(ofSize: 14),
                .foregroundColor: R.color.textBlackColor()!
            ])
            
            attr.addAttributes([
                .link : viewModel.termsUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authTerms())!))
            
            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .font: UIFont.semiBoldFont(ofSize: 14)
                ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authPrivacy())!))
            
            attr.addAttributes([
                .foregroundColor: R.color.textLightGrayColor()!
            ],
                               range: text.nsRange(from: text.range(of: R.string.localizable.authRegisterAgreeToEmailsUnsubscribe())!))
            
            agreeToEmailsTextView.attributedText = attr
            agreeToEmailsTextView.tintColor = R.color.textPinkColor()
            agreeToEmailsTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

    }
    
    @IBOutlet private weak var agrementButton: UIButton!

    // Name section
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var showNameLenghtAlertView: UIView!
    @IBOutlet private weak var usernameExistWarningView: UIView!


    // Gender section
    @IBOutlet private weak var genderPickerView: UIPickerView!

    // Birthday section
    @IBOutlet private weak var birthdayTextField: UITextField! {
        didSet { configure(birthdayTextField) }
    }

    // Sexuality section
    @IBOutlet private weak var sexualityPicker: UIPickerView!
    @IBOutlet weak var sexualityGradientView: SexualityGradientView!

    // Email section
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var emailValidationAlertView: UIView!
    @IBOutlet private weak var emailExistWarningView: UIView!

    // Password section
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var passwordValidationAlertView: UIView!

    // Photo section
    @IBOutlet private var photoInstructionBackgroundViews: [UIView]! {
        didSet {
            photoInstructionBackgroundViews.forEach {
                $0.layer.cornerRadius = 15.0
                $0.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
                $0.layer.borderWidth = 1.0
            }
        }
    }

    @IBOutlet private weak var photoImageView: UIImageView!

    @IBOutlet private weak var sendingImageTitleLabel: UILabel!
    @IBOutlet private weak var sendingImageSubtitleLabel: UILabel!
    @IBOutlet private weak var sendingImageDescriptionLabel: UILabel!
    @IBOutlet private weak var uploadedPhotoImageView: UIImageView!
    @IBOutlet private weak var changeUploadedPhotoButton: UIButton!
    @IBOutlet private weak var changeUploadedPhotoBottomButton: UIButton!
    @IBOutlet private weak var uploadPhotoProblemContainerView: UIView!
    @IBOutlet private weak var uploadPhotoSuccessContainerView: UIView!
    @IBOutlet private weak var uploadPhotoProblemImageView: UIImageView!

    // General
    @IBOutlet private weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var progressView: UIView! {
        didSet {
            progressView.layer.cornerRadius = 1.5
            progressView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet var buttonToKeyboardConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.scrollViewOffsetMuiltiplier
            .drive(onNext: { [unowned self] (x) in
                let horizontalOffset = self.scrollView.frame.size.width * x
                self.scrollView.setContentOffset(.init(x: horizontalOffset, y: 0), animated: true)
            })
            .disposed(by: rx.disposeBag)

        viewModel.showPasswordValidationAlert
            .map { !$0 }
            .drive(passwordValidationAlertView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showEmaillValidationAlert
            .map { !$0 }
            .drive(emailValidationAlertView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showEmailExistWarning
            .map { !$0 }
            .drive(emailExistWarningView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showUsernameExistWarning
            .map { !$0 }
            .drive(usernameExistWarningView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        // buttons management
        viewModel.showDelayedNextButton
            .map { !$0 }
            .drive(delayedStepForwardButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.delayedNextButtonTitle
            .drive(delayedStepForwardButton.rx.title())
            .disposed(by: rx.disposeBag)
        
        viewModel.showContinueButton
            .map { !$0 }
            .drive(stepForwardButton.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showAgreementButton
            .map { !$0 }
            .drive(agrementButton.rx.isHidden)
            .disposed(by: rx.disposeBag)

        viewModel.showChangePhotoButton
            .map { !$0 }
            .drive(changeUploadedPhotoBottomButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        // --

        viewModel.forwardButtonEnabled
            .drive(delayedStepForwardButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.forwardButtonEnabled
            .drive(agrementButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        viewModel.forwardButtonEnabled
            .drive(stepForwardButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.backwardSwipeEnabled
            .drive(backwardSwipeGestureRecognizer.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.forwardSwipeEnabled
            .drive(forwardSwipeGestureRecognizer.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.selecetedDate
            .drive(birthdayTextField.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.selectedPhoto
            .drive(onNext: { [unowned self] (image) in
                self.photoImageView.image = image
                self.uploadPhotoProblemImageView.image = image
            })
            .disposed(by: rx.disposeBag)

        viewModel.photo
            .drive(onNext: { [unowned self] (image) in
                self.uploadedPhotoImageView.image = image
                self.sendingImageTitleLabel.text = (image == nil) ? R.string.localizable.authRegisterAddingMainPhoto() : R.string.localizable.authRegisterMainPhotoAdded()
                self.sendingImageSubtitleLabel.text = (image == nil) ? R.string.localizable.authRegisterAddingMainPhotoSubtitle() : R.string.localizable.authRegisterMainPhotoAddedSubtitle()
                self.sendingImageDescriptionLabel.text = (image == nil) ? R.string.localizable.authRegisterPhotoSending() : R.string.localizable.authRegisterPhotoSent()
            })
            .disposed(by: rx.disposeBag)

        viewModel.showUploadPhotoProblem
            .drive(onNext: { [unowned self] (flag) in
                self.uploadPhotoSuccessContainerView.isHidden = flag
                self.uploadPhotoProblemContainerView.isHidden = !flag
                self.sendingImageTitleLabel.text = flag ? R.string.localizable.authRegisterChangeMainPhoto() : R.string.localizable.authRegisterMainPhotoAdded()
            })
            .disposed(by: rx.disposeBag)

        
        viewModel.currentStep
            .drive(onNext: { [unowned self] (step) in
                
                let x: [RegistrationViewModel.Step: UIResponder] = [
                    .email: self.emailTextField,
                    .password: self.passwordTextField,
                    .name: self.nameTextField,
                    .birthday: self.birthdayTextField
                ]
                
                x[step]?.becomeFirstResponder()
            })
            .disposed(by: rx.disposeBag)

        viewModel.showNameLenghtAlert
            .map { !$0 }
            .drive(showNameLenghtAlertView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        ///extract into extension
        
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

                    let current = self.buttonToKeyboardConstraint.constant
                    self.buttonToKeyboardConstraint.constant = current >= 20.0 ? current : 20.0
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: rx.disposeBag)
        
        ////Name

        nameTextField.rx.text
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.nameChanged(name: x ?? "")
            })
            .disposed(by: rx.disposeBag)
        
        ////birthday
        
        (birthdayTextField.inputView as! UIDatePicker).rx.date
            .skip(1)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.birthdayChanged(date: x)
            })
            .disposed(by: rx.disposeBag)
        
        ////Sexuality
        
        let data = Sexuality.allCasesV2
        
        Observable.just(data)
            .bind(to: sexualityPicker.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.pretty,
                                          attributes: [
                                            NSAttributedString.Key.foregroundColor: UIColor.white,
                                            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 25)
                ])
        }
        .disposed(by: rx.disposeBag)

        sexualityGradientView.sexuality = viewModel.defaultSexuality
        sexualityPicker.selectRow(data.firstIndex(of: viewModel.defaultSexuality)!,
                                  inComponent: 0, animated: false)
        
        sexualityPicker.rx.modelSelected(Sexuality.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.sexualityChanged(sexuality: x.first!)
                self.sexualityGradientView.sexuality = x.first!
            })
            .disposed(by: rx.disposeBag)
        
        ///Gender
        
        let genders = Gender.allCases
        
        Observable.just(genders)
            .bind(to: genderPickerView.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.pretty,
                                          attributes: [
                                            NSAttributedString.Key.foregroundColor: UIColor.white,
                                            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 25)
                ])
        }
        .disposed(by: rx.disposeBag)
        
        genderPickerView.selectRow(genders.firstIndex(of: viewModel.defaultGender)!,
                                   inComponent: 0, animated: false)
        
        genderPickerView.rx.modelSelected(Gender.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.genderChanged(gender: x.first!)
            })
            .disposed(by: rx.disposeBag)
        
        ////email
        
        emailTextField.rx.text
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
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
        
        confirmPasswordTextField.rx.text
            .skip(1)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.confirmPasswordChanged(password: x ?? "")
            })
            .disposed(by: rx.disposeBag)
        
//        agrementTitle.text = immutableNonPersistentState?.legal.title ?? ""
//
//        agrementTextView.attributedText = try? NSAttributedString(data: (immutableNonPersistentState?.legal.description ?? "").data(using: .unicode)!,
//                                                             options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
        
        agrementTextView.font = UIFont.regularFont(ofSize: 15)
        agrementTextView.textColor = R.color.textBlackColor()
        agrementTextView.tintColor = R.color.textPinkColor()
    }
}

extension RegistrationViewController: UIScrollViewDelegate {
    
    @IBAction func back(_ sender: Any) {
        view.endEditing(true)
        viewModel.back()
    }
    
    @IBAction func stepForward(_ sender: Any) {
        view.endEditing(true)
        viewModel.forward()
    }
    
    @IBAction func termsAgreementClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.agreementChanged(agrred: sender.isSelected)
    }
    
    @IBAction func personalDataClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.personalDataChanged(agrred: sender.isSelected)
    }
    
    @IBAction func sensetiveDataClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.sensetiveDataChanged(agrred: sender.isSelected)
    }
    
    @IBAction func agreeToEmailsClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.agreeToReceiveEmailChanged(agrred: sender.isSelected)
    }

    @IBAction func changePhoto(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: R.string.localizable.authRegisterTakePhoto(), style: .default, handler: { _ in
            FantasyCameraViewController.present(on: self) { [unowned self] (image) in
                self.viewModel.photoSelected(photo: image, source: .Taken)
            }
        }))

        alert.addAction(UIAlertAction(title: R.string.localizable.authRegisterChoosePhoto(), style: .default, handler: { _ in

            self.imagePicker = FantasyImagePickerController(presentationController: self) { [unowned self](image) in
                FantasyPhotoEditorViewController.present(on: self, image: image) { [unowned self] (image) in
                    self.viewModel.photoSelected(photo: image, source: .Chosen)
                }
                self.imagePicker = nil
            }

            self.imagePicker?.present()
        }))

        alert.addAction(UIAlertAction(title: R.string.localizable.generalCancel(), style: .cancel, handler:nil))

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backToSignIn(_ sender: Any) {
        viewModel.backToSignIn()
    }

    @IBAction func changeUploadedPhotoButtonClick(_ sender: Any) {
        //        viewModel.pickAnotherPhotoClick()
        changePhoto(sender)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView == self.scrollView else { return }

        let x = scrollView.frame.size.width * (scrollView.contentOffset.x + scrollView.frame.size.width) / scrollView.contentSize.width
        progressWidthConstraint.constant = x
    }
}

private extension RegistrationViewController {
    
    func configure(_ birthdayTextField: UITextField) {

        let picker = UIDatePicker()
        picker.backgroundColor = UIColor.white
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.date = Date(timeIntervalSince1970: 0)
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        birthdayTextField.inputView = picker
        birthdayTextField.allowsEditingTextAttributes = false
    }

}

//MARK:- UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.viewModel.nameChanged(name: "")
        }

        if textField == self.emailTextField {
            self.viewModel.emailChanged(email: "")
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard textField != self.birthdayTextField else { return false }

        if textField == self.emailTextField,
            let text = textField.text,
            let textRange = Range(range, in: text) {
            let x = text.replacingCharacters(in: textRange, with: string)
            return x.first != " " && x.suffix(1) != " "
        }

        if textField == self.nameTextField,
            let text = textField.text,
            let textRange = Range(range, in: text) {

            let x = text.replacingCharacters(in: textRange, with: string)

            let regex = try? NSRegularExpression(pattern: ".*[^A-Za-z0-9& ].*", options: [])
            let result = regex?.firstMatch(in: x, options: [], range: NSMakeRange(0, x.count)) == nil

            return x.first != " " && x.suffix(2) != "  " && result && x.count <= 18
        }

        return true
    }

//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == self.birthdayTextField {
//            return false
//        }
//
//        if textField == self.nameTextField {
//            let range = string.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines)
//
//            return range == nil
//        }
//
//        return true
//    }
}


//MARK:- UITextViewDelegate

extension RegistrationViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        guard UIApplication.shared.canOpenURL(URL) else {
            return false
        }

        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }

}

