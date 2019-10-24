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

    var sections: Driver<[(String, [Row])]> {

        let genders = Gender.allCases.map { $0.rawValue }
        let sexuality = Sexuality.allCases.map { $0.rawValue }

        var res: [(String, [Row])] = [
            ("Teleport", [.city("Madrid")]),
            ("PartnerBody", [.partnerBody(title: "Body", description: "Whom are you looking for?", list: genders, selected: Gender.female.rawValue)]),
            ("PartnerSexuality", [ .partnerSexuality(title: "Sexuality", description: "How Would You Describe Your Partner?", list: sexuality, selected: Sexuality.asexual.rawValue)]),
            ("PartnerAge", [ .age(from: 18, to: 81)]),
            ("Couple", [.couple(false)]),
            ("SecondPartnerBody", [.partnerBody(title: "Body", description: nil, list: genders, selected: Gender.female.rawValue)]),
            ("SecondPartnerSexuality", [ .partnerSexuality(title: "Sexuality", description: nil, list: sexuality, selected: Sexuality.asexual.rawValue)])
        ]

        return Driver.just(res)
    }

    enum Row: IdentifiableType, Equatable {
        case city(String)
        case partnerBody(title: String, description: String?, list: [String], selected: String)
        case partnerSexuality(title: String, description: String?, list: [String], selected: String)
        case age(from: Int, to: Int)
        case couple(Bool)
        case secondPartnerBody(title: String, description: String?, list: [String], selected: String)
        case secondPartnerSexuality(title: String, description: String?, list: [String], selected: String)

        var identity: String {
            switch self {
            case .city(let x):
                return "city \(x)"
            case .partnerBody(let x, let y, let list, let selected):
                return "partnerBody \(x)"
            case .partnerSexuality(let x, let y, let list, let selected):
                return "bio \(y)"
            case .age(let x, let y):
                return "age \(x)"
            case .couple(let q):
                return "couple \(q)"
            case .secondPartnerBody(let x, let y, let list, let selected):
                return "secondPartnerBody \(x)"
            case .secondPartnerSexuality(let x, let y, let list, let selected):
                return "secondPartnerSexuality \(x)"

            }
        }
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
    
    func change(gender: Gender) {
        updateForm { $0.gender = gender }
    }
    
    func change(sexuality: Sexuality) {
        updateForm { $0.sexuality = sexuality }
    }
    
    func changeAgeFrom(x: Int) {
        updateForm { $0.age = x..<$0.age.upperBound }
    }
    
    func changeAgeTo(x: Int) {
        updateForm { $0.age = $0.age.lowerBound..<x }
    }
    
    func openTeleport() {
        router.openTeleport()
    }

    func cancel() {
        router.cancel()
    }

    func submit() {
        
        Dispatcher.dispatch(action: UpdateSearchPreferences(with: form.value))
        router.owner.navigationController?.popViewController(animated: true)
        
    }
    
    private func updateForm(_ mapper: (inout SearchPreferences) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
