//
//  FlirtAccessViewModel.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 5/27/20.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import RxSwift
import RxCocoa

struct FlirtAccessViewModel: MVVM_ViewModel {
 
    let router: FlirtAccessRouter
    
    fileprivate let bag = DisposeBag()
    fileprivate let form = BehaviorRelay(value: EditProfileForm(answers: User.current!.bio.answers))

    init(router: FlirtAccessRouter) {
        self.router = router
        
        form.skip(1) // initial value
            .flatMapLatest { form in
                return UserManager.submitEdits(form: form)
                    .silentCatch(handler: router.owner)
            }
            .subscribe(onNext: { (user) in
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)
    }
    
    func activateFlirtAccess() {
        var x = form.value
        x.flirtAccess = true
        form.accept(x)
    }
}
