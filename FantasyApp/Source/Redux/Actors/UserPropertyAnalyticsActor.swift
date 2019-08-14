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

class UserPropertyAnalyticsActor {
    private let bag = DisposeBag()

    init() {
        appState.changesOf { $0.currentUser }
            .notNil()
            .drive(onNext: { [weak self] user in
            self?.setUserProperties(user)
        }).disposed(by: bag)
    }

    private func setUserProperties(_ user: User) {
        AnalyticsReporter.default.setValue(user.fantasies.count, forProperty: .fantasiesQuantity)
        AnalyticsReporter.default.setValue(user.bio.sexuality, forProperty: .sexuality)
        AnalyticsReporter.default.setValue(user.bio.gender, forProperty: .gender)
        AnalyticsReporter.default.setValue(user.connections.rooms.count, forProperty: .chatRoomsQuantity)
        AnalyticsReporter.default.setValue(user.bio.name, forProperty: .name)
        // AnalyticsReporter.default.setValue(user.bio.age, forProperty: .age)
        // AnalyticsReporter.default.setValue(user.community.name, forProperty: .community)
    }
}
