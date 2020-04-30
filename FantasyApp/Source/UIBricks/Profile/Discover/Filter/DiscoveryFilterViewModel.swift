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

    var isCouple: Bool {
        return form.value.couple != .single
    }

    var age: Range<Int> {
        return form.value.age
    }

    var selectedPartnerGender: Int {
        return Gender.index(by: form.value.gender)
    }

    var selectedPartnerSexuality: Int {
        return Sexuality.index(by: form.value.sexualityV2)
    }

    var selectedSecondPartnerGender: Gender {
        return form.value.couple.partnerGender ?? .male
    }

    var selectedSecondPartnerGenderIndex: Int {
        return Gender.index(by: selectedSecondPartnerGender)
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

struct DiscoveryFilterViewModel : MVVM_ViewModel {
    
    fileprivate let form: BehaviorRelay<SearchPreferences>

    init(router: DiscoveryFilterRouter) {
        self.router = router

        form = .init(value: User.current?.searchPreferences ?? .default)
        
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

    func changeCouple(x: RelationshipStatus) {
        updateForm { $0.couple = x }
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
