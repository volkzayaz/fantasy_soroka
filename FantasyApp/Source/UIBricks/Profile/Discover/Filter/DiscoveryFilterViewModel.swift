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


private enum StoreKeys: String {
    case tutorial = "kTutorialStoreKey"
}

extension DiscoveryFilterViewModel {
    
    var prefs: SearchPreferences {
        return form.value
    }

    var isCouple: Bool {
        return form.value.couple
    }

    var showTutorial: Bool {
        return !UserDefaults.standard.bool(forKey: StoreKeys.tutorial.rawValue)
    }

    var community: Driver<Community?> {
        return form.asDriver().map { $0.community }
    }

    var selectedPartnerGender: Int {
        return Gender.index(by: form.value.gender)
    }

    var selectedPartnerSexuality: Int {
        return Sexuality.index(by: form.value.sexuality)
    }

    var selectedSecondPartnerGender: Int {
        guard let x = form.value.secondPartnerGender else { return 0 }
        return Gender.index(by: x)
    }

    var selectedSecondPartnerSexuality: Int {
        guard let x = form.value.secondPartnerSexuality else {  return 0 }
        return Sexuality.index(by: x)
    }

    var sexualityCount: Int {
        return Sexuality.allCases.count
    }

    var bodiesCount: Int {
        return Gender.allCases.count
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


    fileprivate var showSecondPartner: Bool = false
}

extension DiscoveryFilterViewModel {


    func changeAgeFrom(x: Int) {
        updateForm { $0.age = x..<$0.age.upperBound }
    }
    
    func changeAgeTo(x: Int) {
        updateForm { $0.age = $0.age.lowerBound..<x }
    }

    func changeCouple(x: Bool) {
        updateForm { $0.couple = x }
    }

    func changePartnerGender(gender: Gender) {
        updateForm { $0.gender = gender }
    }

    func changePartnerSexuality(sexuality: Sexuality) {
        updateForm { $0.sexuality = sexuality }
    }

    func changeSecondPartnerGender(gender: Gender) {
        updateForm { $0.secondPartnerGender = gender }
    }

    func changeSecondPartnerSexuality(sexuality: Sexuality) {
        updateForm { $0.secondPartnerSexuality = sexuality }
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
