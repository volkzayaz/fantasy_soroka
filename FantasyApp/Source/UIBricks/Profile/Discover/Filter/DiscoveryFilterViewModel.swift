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

extension DiscoveryFilterViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    
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
