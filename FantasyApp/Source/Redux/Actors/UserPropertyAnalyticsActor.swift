//
//  UserPropertyAnalyticsActor.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 13.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Crashlytics
import Branch

class UserPropertyActor {
    private let bag = DisposeBag()

    init() {
        appState.changesOf { $0.currentUser }
            .notNil()
            .drive(onNext: { user in
                AnalyticsReporter.default.setValue(user.fantasies.liked.count, forProperty: .fantasiesQuantity)
                AnalyticsReporter.default.setValue(user.bio.sexuality.rawValue, forProperty: .sexuality)
                AnalyticsReporter.default.setValue(user.bio.gender.rawValue, forProperty: .gender)
                AnalyticsReporter.default.setValue(user.bio.name, forProperty: .name)
                // AnalyticsReporter.default.setValue(user.bio.age, forProperty: .age)
                // AnalyticsReporter.default.setValue(user.community.name, forProperty: .community)
                
        }).disposed(by: bag)

        appState.changesOf { $0.currentUser }
        .drive(onNext: { user in
                
                Crashlytics.sharedInstance().setUserIdentifier(user?.id)
                Crashlytics.sharedInstance().setUserName(user?.bio.name)
                
                if let id = user?.id {
                    Branch.getInstance()?.setIdentity(id)
                } else {
                    Branch.getInstance()?.logout()
                }
                
            
            })
            .disposed(by: bag)
        
        appState.changesOf { $0.rooms }.drive(onNext: { rooms in
            AnalyticsReporter.default.setValue(rooms.count, forProperty: .chatRoomsQuantity)
        }).disposed(by: bag)
    }
}
