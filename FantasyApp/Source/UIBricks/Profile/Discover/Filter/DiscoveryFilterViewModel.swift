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

enum FilterMode {
    case enableCancel
    case disableCancel
}

private enum StoreKeys: String {
    case tutorial = "kTutorialStoreKey"
}

extension Gender: SwipebleModel {

    var name: String {
        return self.rawValue
    }

   static func gender(by index: Int) -> Gender {
       return allCases[index]
    }

    static func index(by gender: Gender) -> Int {
        return allCases.firstIndex(of: gender) ?? 0
    }
}

extension Sexuality: SwipebleModel {

    var name: String {
        return self.rawValue
    }

   static func sexuality(by index: Int) -> Sexuality {
       return allCases[index]
    }

    static func index(by sexuality: Sexuality) -> Int {
        return allCases.firstIndex(of: sexuality) ?? 0
    }
}

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

    var showTutorial: Bool {
        return !UserDefaults.standard.bool(forKey: StoreKeys.tutorial.rawValue)
    }

    var selectedPartnerGender: Int {
        return Gender.index(by: form.value.gender)
    }

    var selectedPartnerSexuality: Int {
        return Sexuality.index(by: form.value.sexuality)
    }

    var selectedSecondPartnerGender: Gender {
        return form.value.couple.partnerGender ?? .male
    }

    var selectedSecondPartnerGenderIndex: Int {
        return Gender.index(by: selectedSecondPartnerGender)
    }

    var sexualityCount: Int {
        return Sexuality.allCases.count
    }

    var bodiesCount: Int {
        return Gender.allCases.count
    }

    var showCancelButton: Bool {
        return mode == .enableCancel
    }
}

struct DiscoveryFilterViewModel : MVVM_ViewModel {
    
    fileprivate let form: BehaviorRelay<SearchPreferences>
    fileprivate let mode: FilterMode

    init(router: DiscoveryFilterRouter, mode: FilterMode) {
        self.router = router
        self.mode = mode

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
        updateForm { $0.sexuality = sexuality }
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

    func updateTutorial(_ presented: Bool) {
        UserDefaults.standard.set(presented, forKey: StoreKeys.tutorial.rawValue)
    }
    
    private func updateForm(_ mapper: (inout SearchPreferences) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
