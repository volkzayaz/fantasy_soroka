//
//  NotificationSettingsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension NotificationSettingsViewModel {
    
    var currentSettings: NotificationSettings {
        return appStateSlice.currentUser!.notificationSettings
    }
    
}

struct NotificationSettingsViewModel : MVVM_ViewModel {
    
    init(router: NotificationSettingsRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: NotificationSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension NotificationSettingsViewModel {
    
    func changeMatchSettings(state: Bool) {
        Dispatcher.dispatch(action: UpdateNotificationSettings { $0.newMatch = state })
    }
    
    func changeMessageSettings(state: Bool) {
        Dispatcher.dispatch(action: UpdateNotificationSettings { $0.newMessage = state })
    }
    
    func changeFantasyMatchSettings(state: Bool) {
        Dispatcher.dispatch(action: UpdateNotificationSettings { $0.newFantasyMatch = state })
    }
    
}
