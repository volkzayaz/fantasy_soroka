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
            .map { ($0.password?.count ?? 0) < 8 }
    }

    var agreementButtonHidden: Driver<Bool> {
        return step.asDriver()
            .map { $0 != .notice }
    }


    var forwardButtonEnabled: Driver<Bool> {
        return Driver.combineLatest(step.asDriver(), form.asDriver()) { ($0, $1) }
            .map { (step, form) -> Bool in
                
                switch step {
                    
                    ///apply validations here
                case .notice:       return form.agreementTick
                case .name:         return form.name.count > 2
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
        return showNameLenghtAlertVar.asDriver()
    }
}

struct RegistrationViewModel : MVVM_ViewModel {
    
    fileprivate let form = BehaviorRelay(value: RegisterForm())
    
    fileprivate let showNameLenghtAlertVar = BehaviorRelay(value: false)

    fileprivate let step = BehaviorRelay(value: Step.notice)

    
    init(router: RegistrationRouter) {
        self.router = router
        
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
            photoChanged(photo: image)
        }

    }
    

    
    func backToSignIn() {
        router.backToSignIn()
    }
    
    func agreementChanged(agrred: Bool) {
        updateForm { $0.agreementTick = agrred }
    }
    
    func nameChanged(name: String) {
        showNameLenghtAlertVar.accept(name.count < 2)
        updateForm { $0.name = name }
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
        updateForm { $0.email = email }
    }
    
    func passwordChanged(password: String) {
        updateForm { $0.password = password }
    }
    
    func confirmPasswordChanged(password: String) {
        updateForm { $0.confirmPassword = password }
    }

    func photoSelected(photo: UIImage) {
        updateForm { $0.selectedPhoto = photo }
    }
    
    func photoChanged(photo: UIImage) {
        
        ImageValidator.validate(image: photo)
            .subscribe(onSuccess: { (_) in
                self.updateForm { $0.photo = photo }
            }, onError: { (Error) in

            })
            .disposed(by: bag)
            
    }
    
    private func updateForm(_ mapper: (inout RegisterForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
