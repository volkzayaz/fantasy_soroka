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
                self?.addSubscription()
                self?.acceptRoomInviteIfNeeded()
            } else {
                self?.removeSubscription()
            }
        }).disposed(by: bag)
    }

    private func addSubscription() {
        
        guard let userId = User.current?.id else {
            return
        }

        let predicate = NSPredicate(format: "senderId == %@ OR recipientId == %@", userId, userId)
        query = PFQuery(className: Chat.Message.className, predicate: predicate)
        query!.addDescendingOrder("updatedAt")

        let subscription: Subscription<PFObject> = Client.shared.subscribe(query!)
        subscription.handleEvent { object, event in
            switch event {
            case .entered(let message),
                 .created(let message):
                
                print(message)
                
//                let roomDetails: Chat.RoomDetails = [roomObject].toCodable().first!
//                guard var room = appStateSlice.rooms
//                    .first(where: { $0.id == roomDetails.backendId }) else {
//                        return
//                }
//                room.details = roomDetails
//
//               Dispatcher.dispatch(action: UpdateRoom(room: room))
                
            default: break
                
            }
        }
        
        subscription.handleError { (query, er) in
            print(er)
        }
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

    private func removeSubscription() {
        guard let query = query else {
            return
        }
        Client.shared.unsubscribe(query)
    }

    private let bag = DisposeBag()
}
