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

    @IBOutlet private weak var stepForwardButton: UIButton!

    // Notice section
    @IBOutlet private weak var agrementBackgroundRoundedView: UIView! {
        didSet {
            agrementBackgroundRoundedView.addFantasyRoundedCorners()
        }
    }
    @IBOutlet private weak var agrementTextView: UITextView! {
        didSet {
            agrementTextView.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

            let text = agrementTextView.text ?? ""
            let attr = NSMutableAttributedString(attributedString: agrementTextView.attributedText)

            attr.addAttributes([
                .link : viewModel.reportUrl,
                .underlineStyle: NSUnderlineStyle.single.rawValue],
                               range: text.nsRange(from: text.range(of: "feedback.fantasyapp.com ")!))
            agrementTextView.attributedText = attr
            agrementTextView.font = UIFont.regularFont(ofSize: 15)
            agrementTextView.textColor = R.color.textBlackColor()
            agrementTextView.tintColor = R.color.textPinkColor()
        }
    }

    @IBOutlet private weak var termsTextView: UITextView! {
        didSet {
            let text = "I agree to the Terms of Service, Privacy Policy and Fantasy Community Rules."
            let attr = NSMutableAttributedString(string: text)

            attr.addAttributes([
                .link : viewModel.termsUrl,
                .underlineStyle: NSUnderlineStyle.single.rawValue],
                               range: text.nsRange(from: text.range(of: "Terms of Service")!))

            attr.addAttributes([
                .link : viewModel.privacyUrl,
                .underlineStyle: NSUnderlineStyle.single.rawValue],
                               range: text.nsRange(from: text.range(of: "Privacy Policy")!))

            attr.addAttributes([
                .link : viewModel.communityRulesUrl,
                .underlineStyle: NSUnderlineStyle.single.rawValue],
                               range: text.nsRange(from: text.range(of: "Fantasy Community Rules")!))

            termsTextView.attributedText = attr
            termsTextView.font = UIFont.regularFont(ofSize: 15)
            termsTextView.textColor = R.color.textBlackColor()
            termsTextView.tintColor = R.color.textBlackColor()
            termsTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

    // Partner section
    @IBOutlet private weak var partnerBodyLabel: UILabel!
    @IBOutlet private weak var partnerBodyPickerView: UIPickerView!
    @IBOutlet private weak var soloPartnerButton: PrimaryButton! {
        didSet {
            soloPartnerButton.mode = .selector
        }
    }
    @IBOutlet private weak var couplePartnerButton: PrimaryButton! {
        didSet {
            couplePartnerButton.mode = .selector
        }
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
    @IBOutlet var buttonToKeybosrdConstraint: NSLayoutConstraint!

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
            .drive(agrementButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        viewModel.forwardButtonEnabled
            .drive(stepForwardButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        viewModel.partnersGenderHidden
            .drive(partnerBodyLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.partnersGenderHidden
            .drive(partnerBodyPickerView.rx.isHidden)
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
                self.sendingImageTitleLabel.text = (image == nil) ? "Adding Main Photo" : "Main Photo Added"
                self.sendingImageDescriptionLabel.text = (image == nil) ? "Photo sending…" : "Your photo was sent"
            })
            .disposed(by: rx.disposeBag)

        viewModel.showUploadPhotoProblem
            .drive(onNext: { [unowned self] (flag) in
                self.uploadPhotoSuccessContainerView.isHidden = flag
                self.uploadPhotoProblemContainerView.isHidden = !flag
                self.sendingImageTitleLabel.text = flag ? "Change Main Photo" : "Adding Main Photo"
            })
            .disposed(by: rx.disposeBag)

        
        viewModel.currentStep
            .drive(onNext: { [unowned self] (step) in
                
                let x: [RegistrationViewModel.Step: UIResponder] = [
                    .name: self.nameTextField,
                    .birthday: self.birthdayTextField,
                    .email: self.emailTextField,
                    .password: self.passwordTextField
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
                    self.buttonToKeybosrdConstraint.constant += delta

                    let current = self.buttonToKeybosrdConstraint.constant
                    self.buttonToKeybosrdConstraint.constant = current >= 20.0 ? current : 20.0
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
        
        let data = Sexuality.allCases
        
        Observable.just(data)
            .bind(to: sexualityPicker.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.rawValue,
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

        ///Relationship
        
        Observable.just(genders)
            .bind(to: partnerBodyPickerView.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.pretty,
                                          attributes: [
                                            NSAttributedString.Key.foregroundColor: UIColor.white,
                                            NSAttributedString.Key.font: UIFont.regularFont(ofSize: 25)
                ])
        }
        .disposed(by: rx.disposeBag)
        
        partnerBodyPickerView.selectRow(genders.firstIndex(of: viewModel.defaultGender)!,
                                        inComponent: 0, animated: false)
        
        partnerBodyPickerView.rx.modelSelected(Gender.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.relationshipChanged(status: .couple(partnerGender: x.first!))
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
    
    @IBAction func relationshipChanged(_ sender: UIButton) {

        soloPartnerButton.isSelected = sender.tag == 1
        couplePartnerButton.isSelected = sender.tag != 1

        if sender.tag == 1 {
            viewModel.relationshipChanged(status: .single)
        }
        else {
            viewModel.relationshipChanged(status: .couple(partnerGender: .female))
        }
        
    }

    @IBAction func changePhoto(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            FantasyCameraViewController.present(on: self) { [unowned self] (image) in
                self.viewModel.photoSelected(photo: image)
            }
        }))

        alert.addAction(UIAlertAction(title: "Choose a Photo", style: .default, handler: { _ in

            self.imagePicker = FantasyImagePickerController(presentationController: self) { [unowned self](image) in
                FantasyPhotoEditorViewController.present(on: self, image: image) { [unowned self] (image) in
                    self.viewModel.photoSelected(photo: image)
                }
                self.imagePicker = nil
            }

            self.imagePicker?.present()

            //            FMPhotoImagePicker.present(on: self) { [unowned self] (image) in
            //                FantasyPhotoEditorViewController.present(on: self, image: image) { [unowned self] (image) in
            //                    self.viewModel.photoSelected(photo: image)
            //                }
            //            }
        }))

        alert.addAction(UIAlertAction(title: "Choose a Photo", style: .cancel, handler:nil))

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
        birthdayTextField.inputView = picker
        birthdayTextField.allowsEditingTextAttributes = false
    }

}

//MARK:- UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard textField != self.birthdayTextField else { return false }
        guard textField == self.nameTextField else { return true }

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)

            let regex = try? NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
            let result = regex?.firstMatch(in: updatedText, options: [], range: NSMakeRange(0, updatedText.count)) == nil

            return updatedText.first != " " && updatedText.suffix(2) != "  " && result
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

