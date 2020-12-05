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
        return currentStep.map { CGFloat($0.rawValue) / CGFloat(divisor) }
    }
    
    var scrollViewOffsetMuiltiplier: Driver<CGFloat> {
        return currentStep.map { CGFloat($0.rawValue - 1) }
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

    var showDelayedNextButton: Driver<Bool> {
        return currentStep.asDriver()
            .map { $0 == .onboarding1 || $0 == .onboarding2 || $0 == .onboarding3 }
    }
    
    var delayedNextButtonTitle: Driver<String> {
        onboardingTimer.map {
            ($0 > 0) ? R.string.localizable.registrationOnboardingWaitFormat($0) : R.string.localizable.registrationOnboardingNextButton()
        }
    }
    
    var showContinueButton: Driver<Bool> {
        return Driver.combineLatest(showDelayedNextButton, showAgreementButton, showChangePhotoButton)
            .map { !$0 && !$1 && !$2 }
    }

    var showAgreementButton: Driver<Bool> {
        return currentStep
            .map { $0 == .notice }
    }

    var showChangePhotoButton: Driver<Bool> {
        return Driver.merge([currentStep.map { $0 == .addingPhoto},
                             showUploadPhotoProblem])
    }

    var forwardButtonEnabled: Driver<Bool> {
        return Driver.combineLatest(
        currentStep,
        reachedStepRelay.asDriver(),
        onboardingTimer,
        form.asDriver(),
        emailRelay.asDriver(),
        showEmailExistVar.asDriver()
        ).map { (currentStep, reachedStep, onboardingTimer, form, tmpEmail, emailExist) -> Bool in
                
                switch currentStep {
                    
                    ///apply validations here
                case .onboarding1, .onboarding2, .onboarding3:
                    return onboardingTimer <= 0
                case .notice:
                    return form.agreementTick && form.personalDataTick && form.sensetiveDataTick && form.agreeToEmailsTick
                
                case .email:        return (form.email?.isValidEmail ?? false) && (tmpEmail?.isValidEmail ?? false) && emailExist == false
                case .password:     return form.password == form.confirmPassword && form.password != nil && (form.password?.count ?? 0) > 7
                case .name:         return form.name.isValidUsernameLenght
                case .birthday:     return form.brithdate != nil
                case .sexuality:    return true
                case .gender:       return true
                case .lookingFor:   return form.lookingFor.count > 0
                case .photo:        return form.selectedPhoto != nil
                case .addingPhoto:        return form.photo != nil
                }
                    
            }
    }
    
    var backwardSwipeEnabled: Driver<Bool> {
        currentStep.map { $0 == .onboarding2 || $0 == .onboarding3 }
    }
    
    var forwardSwipeEnabled: Driver<Bool> {
        Driver.combineLatest(currentStep, onboardingTimer)
            .map { step, timer in
                (step == .onboarding1 || step == .onboarding2) && timer <= 0
            }
    }
    
    var selecetedDate: Driver<String> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd yyyy"

        return form.asDriver().map { $0.brithdate }
            .notNil()
            .map { dateFormatter.string(from: $0) }
    }
    
    var availableLookingFor: [LookingFor] {
        [.flirtForHookup, .flirtForLongTermDating, .flirtForNewFriends, .flirtForShortTermDating]
    }
    
    var selectedPhoto: Driver<UIImage?> {
        return form.asDriver().map { $0.selectedPhoto?.image }
    }

    var photo: Driver<UIImage?> {
        return form.asDriver().map { $0.photo }
    }
    
    var defaultGender: Gender { return .female }
    var defaultSexuality: Sexuality { return .heteroflexible }
    
    var currentStep: Driver<Step> {
        return currentStepRelay.asDriver()
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

class RegistrationViewModel : MVVM_ViewModel {
    
    fileprivate let form = BehaviorRelay(value: RegisterForm())
    fileprivate let currentStepRelay = BehaviorRelay(value: Step.onboarding1)
    fileprivate let reachedStepRelay = BehaviorRelay(value: Step.onboarding1)
    
    fileprivate var onboardingTimer: Driver<Int> {
        currentStepRelay.filter { $0 == .onboarding1 || $0 == .onboarding2 || $0 == .onboarding3 }
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                guard let `self` = self else {
                    return .just(0)
                }
                
                return Observable.concat(Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
                    .map { 5 - $0 }
                    .takeWhile { $0 >= 0 }
                    .takeUntil(BehaviorRelay.combineLatest(self.currentStepRelay, self.reachedStepRelay).filter { $0 != $1 } )
                    ,.just(0))
            }.asDriver(onErrorJustReturn: 0)
    }

    // forms with errors
    fileprivate let showUploadPhotoProblemVar = BehaviorRelay(value: false)
    fileprivate let showUsernameExistVar = BehaviorRelay(value: false)
    fileprivate let showEmailExistVar = BehaviorRelay(value: false)
    
    fileprivate let emailRelay = BehaviorRelay<String?>(value: nil)
    
    fileprivate var timerSpentForRegistration = TimeSpentCounter()
    
    init(router: RegistrationRouter) {
        self.router = router

        let updateEmail = self.updateForm
        
        emailRelay
            .notNil()
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
     
        timerSpentForRegistration.start()
        Analytics.setUserProps(props: ["Profile Status: Type": "Incomplete Sign-Up"])
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
        
        reachedStepRelay
            .bind(to: currentStepRelay)
            .disposed(by: bag)
    }
    
    let router: RegistrationRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
 
    enum Step: Int, CaseIterable {
        
        case onboarding1 = 1
        case onboarding2
        case onboarding3
        case notice
        case email
        case password
        case name
        case gender
        case birthday
        case lookingFor
        case sexuality
        case photo
        case addingPhoto
    }
}

extension RegistrationViewModel {
    
    func back() {
        guard currentStepRelay.value.rawValue != 1 else {
            router.dismiss()
            return
        }
        
        let prev = Step(rawValue: currentStepRelay.value.rawValue - 1)!
        
        currentStepRelay.accept( prev )
    }
    
    func forward() {
        
        ///fixme: I'm not really a 21 year old
        let years21: TimeInterval = -1 * 3600 * 24 * 366 * 21
        
        if currentStepRelay.value == .birthday,
            let d = form.value.brithdate,
            d.timeIntervalSinceNow > years21 {
            
            SettingsStore.ageRestriction.value = d
            Analytics.report(Analytics.Event.SignUpPassed.birthdayFailed)
            
            return
        }
        
        let nextStep = Step(rawValue: currentStepRelay.value.rawValue + 1)
        if nextStep != reachedStepRelay.value {
            reportStepPassed(step: reachedStepRelay.value)
        }
        
        guard let next = nextStep else {
            var timerCopy = timerSpentForRegistration
            
            AuthenticationManager.finishRegistration(with: form.value)
                .trackView(viewIndicator: indicator)
                .silentCatch(handler: router.owner)
                .subscribe(onNext: { (user) in
                    Dispatcher.dispatch(action: SetUser(user: user))
                    
                    Analytics.report(Analytics.Event.SignUpPassed.completed(from: .SignUp,
                                                                            timeSpent: timerCopy.finish()))
                })
                .disposed(by: bag)
            
            return
        }
        
        if currentStepRelay.value.rawValue == Step.email.rawValue {
            AuthenticationManager.registerIncomplete(with: form.value)
                .trackView(viewIndicator: indicator)
                .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in
                self.reachedStepRelay.accept(next)
            }).disposed(by: bag)
            
            return
        }
        
        if currentStepRelay.value == reachedStepRelay.value {
            reachedStepRelay.accept(next)
        } else {
            currentStepRelay.accept(next)
        }

        // start photo uploading
        if currentStepRelay.value == .addingPhoto,
            let image = form.value.selectedPhoto {
            photoSelected(photo: image.image, source: image.source)
        }
    }
    
    func backToSignIn() {
        router.backToSignIn()
    }
    
    func agreementChanged(agrred: Bool) {
        updateForm { $0.agreementTick = agrred }
    }
    
    func personalDataChanged(agrred: Bool) {
        updateForm { $0.personalDataTick = agrred }
    }
    
    func sensetiveDataChanged(agrred: Bool) {
        updateForm { $0.sensetiveDataTick = agrred }
    }
    
    func agreeToReceiveEmailChanged(agrred: Bool) {
        updateForm { $0.agreeToEmailsTick = agrred }
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
    
    func lookingForChanged(index: Int, isSelected: Bool) {
        let lookingFor = availableLookingFor[index]
        updateForm {
            $0.lookingFor.removeAll(where: { $0 == lookingFor })
            if isSelected {
                $0.lookingFor.append(lookingFor)
            }
        }
    }
    
    func sexualityChanged(sexuality: Sexuality) {
        updateForm { $0.sexuality = sexuality }
    }
    
    func genderChanged(gender: Gender) {
        updateForm { $0.gender = gender }
    }
    
    func emailChanged(email: String) {
        showEmailExistVar.accept(false)
        emailRelay.accept(email)
    }
    
    func passwordChanged(password: String) {
        updateForm { $0.password = password }
    }
    
    func confirmPasswordChanged(password: String) {
        updateForm { $0.confirmPassword = password }
    }

    func photoSelected(photo: UIImage, source: Analytics.Event.SignUpPassed.PhotoSource) {
        updateForm { $0.photo = nil }
        showUploadPhotoProblemVar.accept(false)
        updateForm { $0.selectedPhoto = .init(image: photo, source: source) }

        if currentStepRelay.value == .addingPhoto {
            photoChanged(photo: photo, source: source)
            return
        }

        forward()
    }
    
    func photoChanged(photo: UIImage, source: Analytics.Event.SignUpPassed.PhotoSource) {
        
        ImageValidator.validate(image: photo)
            .subscribe(onSuccess: { (_) in
                self.updateForm { $0.photo = photo }
                self.showUploadPhotoProblemVar.accept(false)
                
                Analytics.report(Analytics.Event.SignUpPassed.photoUploadGood)
                
            }, onError: { (Error) in
                self.showUploadPhotoProblemVar.accept(true)
                
                Analytics.report(Analytics.Event.SignUpPassed.photoUploadBad)
                
            })
            .disposed(by: bag)
            
        Analytics.report(Analytics.Event.SignUpPassed.photo(from: source))
    }
    
    private func updateForm(_ mapper: (inout RegisterForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }

}

extension RegistrationViewModel {
    
    private func reportStepPassed(step: Step) {
        
        let event: Analytics.Event.SignUpPassed
        switch step {
        case .onboarding1:
            event = .onboarding1
        case .onboarding2:
            event = .onboarding2
        case .onboarding3:
            event = .onboarding3
        case .notice:
            event = .notice
        case .email:
            event = .email
        case .password:
            event = .password
        case .name:
            event = .name
        case .gender:
            event = .gender
        case .birthday:
            event = .birthdayFilled
        case .lookingFor:
            event = .lookingFor
        case .sexuality:
            event = .sexuality
            
        case .photo, .addingPhoto: return
        }
         
        Analytics.report(event)
        
    }
    
}
