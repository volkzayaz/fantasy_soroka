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
    
    @IBOutlet private weak var stepBackButton: UIButton!
    @IBOutlet private weak var stepForwardButton: UIButton!
    
    @IBOutlet private weak var agrementSwitch: UISwitch!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var birthdayTextField: UITextField! {
        didSet { configure(birthdayTextField) }
    }
    @IBOutlet private weak var sexualityPicker: UIPickerView!
    @IBOutlet private weak var genderPickerView: UIPickerView!
    
    @IBOutlet private weak var partnerBodyLabel: UILabel!
    @IBOutlet private weak var partnerBodyPickerView: UIPickerView!
    
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var progressView: UIView!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var buttonToKeybosrdConstraint: NSLayoutConstraint!
    
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
            .bind(to: sexualityPicker.rx.itemTitles) { _, item in
                return item.rawValue
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
            .bind(to: genderPickerView.rx.itemTitles) { _, item in
                return item.rawValue
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
        
        Observable.just(Gender.allCases)
            .bind(to: partnerBodyPickerView.rx.itemTitles) { _, item in
                return item.rawValue
            }
            .disposed(by: rx.disposeBag)
        
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
    
    @IBAction func forgotPassword(_ sender: Any) {
        viewModel.resetPassword()
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
    
    @IBAction func termsAgreementChange(_ sender: Any) {
        viewModel.agreementChanged(agrred: agrementSwitch.isOn)
    }
    
    @IBAction func relationshipChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            viewModel.relationshipChanged(status: .single)
        }
        else {
            viewModel.relationshipChanged(status: .couple(partnerGender: .female))
        }
        
    }
    
    @IBAction func changePhoto(_ sender: Any) {
        FDTakeImagePicker.present(on: self) { [unowned self] (image) in
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
        picker.datePickerMode = .date
        
        picker.maximumDate = Date()
        picker.date = Date(timeIntervalSince1970: 0)
        
        birthdayTextField.inputView = picker
        
    }
    
}
