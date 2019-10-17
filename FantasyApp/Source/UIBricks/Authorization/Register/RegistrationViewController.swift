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
    
    var viewModel: RegistrationViewModel!

    @IBOutlet private weak var stepForwardButton: UIButton!

    // Notice section
    @IBOutlet private weak var agrementBackgroundRoundedView: UIView!
    @IBOutlet private weak var agrementTextView: UITextView!
    @IBOutlet private weak var agrementLabel: UILabel! {
        didSet {
            agrementLabel.font = UIFont.regularFont(ofSize: 15)
        }
    }

    @IBOutlet private weak var agrementButton: UIButton!

    // Name section
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var showNameLenghtAlertView: UIView!

    // Gender section
    @IBOutlet private weak var genderPickerView: UIPickerView!

    // Birthday section

    @IBOutlet private weak var birthdayTextField: UITextField! {
        didSet { configure(birthdayTextField) }
    }

    @IBOutlet private weak var sexualityPicker: UIPickerView!

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

    // Email section
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var emailValidationAlertView: UIView!

    // Password section
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var passwordValidationAlertView: UIView!

    // Photo section
    @IBOutlet private weak var photoInstructionBackgroundView: UIView! {
        didSet {
            photoInstructionBackgroundView.layer.cornerRadius = 15.0
            photoInstructionBackgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            photoInstructionBackgroundView.layer.borderWidth = 1.0
        }
    }

    @IBOutlet private weak var photoImageView: UIImageView!
    
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
            .drive(photoImageView.rx.image)
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
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: rx.disposeBag)
        
        ////Name
        
        nameTextField.rx.text
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
        
        sexualityPicker.selectRow(data.firstIndex(of: viewModel.defaultSexuality)!,
                                  inComponent: 0, animated: false)
        
        sexualityPicker.rx.modelSelected(Sexuality.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.sexualityChanged(sexuality: x.first!)
            })
            .disposed(by: rx.disposeBag)
        
        ///Gender
        
        let genders = Gender.allCases
        
        Observable.just(genders)
            .bind(to: genderPickerView.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.rawValue,
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
                 return NSAttributedString(string: item.rawValue,
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
        FMPhotoImagePicker.present(on: self) { [unowned self] (image) in
            self.viewModel.photoChanged(photo: image)
        }
    }
    
    @IBAction func backToSignIn(_ sender: Any) {
        viewModel.backToSignIn()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    }

}
