//
//  RoomsActor.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import ParseLiveQuery
import Branch

class RoomsActor {
    var query: PFQuery<PFObject>?

    init() {
        appState.changesOf { $0.currentUser?.id }
            .drive(onNext: { [weak self] user in
            if user != nil {
                self?.acceptRoomInviteIfNeeded()
            }
        }).disposed(by: bag)
    }

    private func acceptRoomInviteIfNeeded() {
        guard let sessionParams = Branch.getInstance()?.getLatestReferringParams() as? [String: AnyObject],
            let invitationLink = sessionParams["invitationLink"] as? String else {
                return
        }
        RoomManager.acceptInviteToRoom(invitationLink).subscribe({ [weak self] room in
            guard let self = self else { return }

        }).disposed(by: bag)
    }

    private let bag = DisposeBag()
}
