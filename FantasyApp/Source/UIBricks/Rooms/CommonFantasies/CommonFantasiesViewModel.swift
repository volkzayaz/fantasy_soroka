//
//  ChatViewModel.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct CommonFantasiesViewModel: MVVM_ViewModel {
    let router: CommonFantasiesRouter
    let room: Chat.RoomDetails

    init(router: CommonFantasiesRouter, room: Chat.RoomDetails) {
        self.router = router
        self.room = room

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}
