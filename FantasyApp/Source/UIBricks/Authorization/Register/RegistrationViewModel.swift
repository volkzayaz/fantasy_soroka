//
//  RegistrationViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import CoreImage

import RxSwift
import RxCocoa

extension RegistrationViewModel {

    var showUploadPhotoProblem: Driver<Bool> {
           return showUploadPhotoProblemVar.asDriver()
       }

    var progressViewMultiplier: Driver<CGFloat> {
        let divisor = Step.allCases.last!.rawValue
        return step.asDriver().map { CGFloat($0.rawValue) / CGFloat(divisor) }
    }
    
    var scrollViewOffsetMuiltiplier: Driver<CGFloat> {
        return step.asDriver().map { CGFloat($0.rawValue - 1) }
    }

    var showEmaillValidationAlert: Driver<Bool> {
        return form.asDriver()
            .map { (form) -> Bool in
                guard let email = form.email,
                    email.count > 0 else { return false}

                return !email.isValidEmail
        }
    }

    var showPasswordValidationAlert: Driver<Bool> {
        return form.asDriver()
            .map { ($0.password?.count ?? 0) < 8 && ($0.password?.count ?? 0) > 0}
    }

    var showContinueButton: Driver<Bool> {
        return Driver.combineLatest(showAgreementButton, showChangePhotoButton)
            .map { !$0.0 && !$0.1 }
    }

    var showAgreementButton: Driver<Bool> {
        return step.asDriver()
            .map { $0 == .notice }
    }

    var showChangePhotoButton: Driver<Bool> {
        return Driver.merge([step.asDriver().map { $0 == .addingPhoto},
                             showUploadPhotoProblem])
    }

    var forwardButtonEnabled: Driver<Bool> {
        return Driver.combineLatest(step.asDriver(), form.asDriver()) { ($0, $1) }
            .map { (step, form) -> Bool in
                
                switch step {
                    
                    ///apply validations here
                case .notice:       return form.agreementTick
                case .name:         return form.name.isValidUsernameLenght
                case .birthday:     return form.brithdate != nil
                case .sexuality:    return true
                case .gender:       return true
                case .relationship: return form.relationshipStatus != nil
                case .email:        return form.email?.isValidEmail ?? false
                case .password:     return form.password == form.confirmPassword && form.password != nil && (form.password?.count ?? 0) > 7
                
                case .photo:        return form.selectedPhoto != nil
                case .addingPhoto:        return form.photo != nil
                }
                    
            }
    }
    
    var partnersGenderHidden: Driver<Bool> {
        return form.asDriver().map { x in
            if case .couple(_)? = x.relationshipStatus { return false }
            
            return true
        }
    }
    
    var selecetedDate: Driver<String> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd yyyy"

        return form.asDriver().map { $0.brithdate }
            .notNil()
            .map { dateFormatter.string(from: $0) }
    }
    
    var selectedPhoto: Driver<UIImage?> {
        return form.asDriver().map { $0.selectedPhoto }
    }

    var photo: Driver<UIImage?> {
        return form.asDriver().map { $0.photo }
    }
    
    var defaultGender: Gender { return .female }
    var defaultSexuality: Sexuality { return .heteroflexible }
    
    var currentStep: Driver<Step> {
        return step.asDriver()
    }

    var showNameLenghtAlert: Driver<Bool> {
        return form.asDriver().map { $0.name.count }
            .map { $0 > 0 && $0 <= 1 }
    }

    var showUsernameExistWarning: Driver<Bool> {
        return showUsernameExistVar.asDriver()
    }

    var showEmailExistWarning: Driver<Bool> {
        return showEmailExistVar.asDriver()
    }

    var reportUrl: String { return "https://feedback.fantasyapp.com/" }
    var termsUrl: String { return "https://fantasyapp.com/en/terms-and-conditions/" }
    var privacyUrl: String { return "https://fantasyapp.com/en/privacy-policy/" }
    var communityRulesUrl: String { return "https://fantasyapp.com/en/community-rules/" }
}

struct RegistrationViewModel : MVVM_ViewModel {
    
    fileprivate let form = BehaviorRelay(value: RegisterForm())
    fileprivate let step = BehaviorRelay(value: Step.notice)

    // forms with errors
    fileprivate let showUploadPhotoProblemVar = BehaviorRelay(value: false)
    fileprivate let showUsernameExistVar = BehaviorRelay(value: false)
    fileprivate let showEmailExistVar = BehaviorRelay(value: false)
    
    fileprivate let emailRelay = BehaviorRelay<String?>(value: nil)
    
    init(router: RegistrationRouter) {
        self.router = router

        let updateEmail = self.updateForm
        
        emailRelay.notNil()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .filter { $0.isValidEmail }
            .flatMapLatest { (email) -> Single<Bool> in
                
                let clearEmail = email.trimmingCharacters(in: .whitespaces)
                
                return AuthenticationManager.isUnique(email: clearEmail)
                    .do(onSuccess: { (isValid) in
                        if isValid {
                            updateEmail { $0.email = email }
                        }
                    })
            }
            .map { !$0 }
            .bind(to: showEmailExistVar)
            .disposed(by: bag)
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: RegistrationRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
 
    enum Step: Int, CaseIterable {
        
        case notice = 1
        case name
        case gender
        case birthday
        case relationship
        case sexuality
        case email
        case password
        case photo
        case addingPhoto
    }
}

extension RegistrationViewModel {
    
    func back() {
        guard step.value.rawValue != 1 else {
            router.dismiss()
            return
        }
        
        let prev = Step(rawValue: step.value.rawValue - 1)!
        
        step.accept( prev )
    }
    
    func forward() {
        
        ///fixme: I'm not really a 21 year old
        let years21: TimeInterval = -1 * 3600 * 24 * 366 * 21
        
        if step.value == .birthday,
            let d = form.value.brithdate,
            d.timeIntervalSinceNow > years21 {
            
            SettingsStore.ageRestriction.value = d
            
            return
        }
        
        guard let next = Step(rawValue: step.value.rawValue + 1) else {
            
            AuthenticationManager.register(with: form.value)
                .trackView(viewIndicator: indicator)
                .silentCatch(handler: router.owner)
                .subscribe(onNext: { (user) in
                    Dispatcher.dispatch(action: SetUser(user: user))
                })
                .disposed(by: bag)
            
            return
        }
        
        step.accept( next )

        // start photo uploading
        if step.value == .addingPhoto,
            let image = form.value.selectedPhoto {
            photoSelected(photo: image)
        }
    }
    
    func backToSignIn() {
        router.backToSignIn()
    }
    
    func agreementChanged(agrred: Bool) {
        updateForm { $0.agreementTick = agrred }
    }

    func nameChanged(name: String) {
        
        let clearName = name.trimmingCharacters(in: .whitespaces)

                Observable.just(clearName)
        //            .filter { $0.isValidUsernameLenght }
        //            .flatMap { self.validateName(name: $0) }
                    .subscribe(onNext: { (_) in

                        let isValid = true
                        
                        // show that username not valid
                        self.showUsernameExistVar.accept(!isValid)

                        if isValid {
                            self.updateForm { $0.name = clearName }
                        }
                    }).disposed(by: bag)
        
    }
    
    func birthdayChanged(date: Date) {
        updateForm { $0.brithdate = date }
    }
    
    func sexualityChanged(sexuality: Sexuality) {
        updateForm { $0.sexuality = sexuality }
    }
    
    func genderChanged(gender: Gender) {
        updateForm { $0.gender = gender }
    }
    
    func relationshipChanged(status: RelationshipStatus) {
        updateForm { $0.relationshipStatus = status }
    }
    
    func emailChanged(email: String) {
        emailRelay.accept(email)
    }
    
    func passwordChanged(password: String) {
        updateForm { $0.password = password }
    }
    
    func confirmPasswordChanged(password: String) {
        updateForm { $0.confirmPassword = password }
    }

    func photoSelected(photo: UIImage) {
        updateForm { $0.photo = nil }
        showUploadPhotoProblemVar.accept(false)
        updateForm { $0.selectedPhoto = photo }

        if step.value == .addingPhoto {
            photoChanged(photo: photo)
            return
        }

        forward()
    }
    
    func photoChanged(photo: UIImage) {
        
        ImageValidator.validate(image: photo)
            .subscribe(onSuccess: { (_) in
                self.updateForm { $0.photo = photo }
                self.showUploadPhotoProblemVar.accept(false)
            }, onError: { (Error) in
                self.showUploadPhotoProblemVar.accept(true)
            })
            .disposed(by: bag)
            
    }
    
    private func updateForm(_ mapper: (inout RegisterForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }

}
