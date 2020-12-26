//
//  DiscoveryFilterViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension DiscoveryFilterViewModel {
    
    var prefs: SearchPreferences {
        return form.value
    }

    var community: Driver<Community?> {
        return appState.changesOf { $0.currentUser?.community.value }
    }
    
    var globalMode: Driver<Bool> {
        return form.asDriver().map { $0.globalMode ?? false }
    }

    var age: Range<Int> {
        return form.value.age
    }
    
    var ageDriver: Driver<Range<Int>> {
        return form.asDriver().map { $0.age }
    }

    var selectedPartnerGender: Int {
        return Gender.index(by: form.value.gender)
    }

    var selectedPartnerSexuality: Int {
        return Sexuality.index(by: form.value.sexualityV2)
    }

    var sexualityCount: Int {
        return Sexuality.allCasesV2.count
    }

    var bodiesCount: Int {
        return Gender.allCases.count
    }

    var showLocationSection: Driver<Bool> {
        return .just(true) //appState.map { $0.currentUser?.searchPreferences != nil }
    }
}

class DiscoveryFilterViewModel : MVVM_ViewModel {
    
    fileprivate let form: BehaviorRelay<SearchPreferences>

    init(router: DiscoveryFilterRouter) {
        self.router = router
        form = .init(value: User.current?.searchPreferences ?? .default)
        
        if User.current?.subscription.isSubscribed != true {
            appState.changesOf { $0.currentUser?.subscription.isSubscribed }
                .asObservable()
                .filter { $0 == true }
                .first()
                .subscribe { [unowned self] _ in
                    var form = self.form.value
                    form.globalMode = true
                    
                    self.form.accept(form)
                }.disposed(by: bag)
        }
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: DiscoveryFilterRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension DiscoveryFilterViewModel {

    func changeAge(x: Range<Int>) {
        updateForm { $0.age = x }
    }

    func changePartnerGender(gender: Gender) {
        updateForm { $0.gender = gender }
    }

    func changePartnerSexuality(sexuality: Sexuality) {
        updateForm { $0.sexualityV2 = sexuality }
    }

    func openTeleport() {
        router.openTeleport()
    }
    
    func changeGlobalMode(isEnabled: Bool) {
        if isEnabled && User.current?.subscription.isSubscribed != true {
            router.showSubscription()
            updateForm { $0.globalMode = false }
        } else {
            updateForm { $0.globalMode = isEnabled }
        }
    }

    func cancel() {
        router.cancel()
    }

    func submit() {
        
        Dispatcher.dispatch(action: UpdateSearchPreferences(with: form.value))
        router.owner.navigationController?.dismiss(animated: true, completion: nil)
    }

    private func updateForm(_ mapper: (inout SearchPreferences) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
}
