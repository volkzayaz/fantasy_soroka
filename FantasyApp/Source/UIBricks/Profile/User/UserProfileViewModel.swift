//
//  UserProfileViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension UserProfileViewModel {
    
    var photos: Driver<[AnimatableSectionModel<String, Photo>]> {
        
        let photosDriver = UserManager
            .images(of: user)
            .trackView(viewIndicator: indicator)
            .silentCatch()
            .asDriver(onErrorJustReturn: ([], []))
        
        return Driver.combineLatest(photosDriver,
                                    relationshipState.asDriver().notNil()) { ($0, $1) }
            .map { (userPhotos, relation) in
                
                var includesPrivatePhotos = false
                if case .mutual = relation {
                    includesPrivatePhotos = true
                }

                return Photo.fromPhotos(public: userPhotos.0,
                                        private: userPhotos.1,
                                        includePrivate: includesPrivatePhotos)
            }
            .map { [AnimatableSectionModel(model: "", items: $0)] }
            
    }

    var sections: Driver<[(String, [Row])]> {
        
        let u = user
        return relationshipState
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                switch (lhs, rhs) {
                    
                case (_, .mutual(_)): return false
                default: return true
                    
                }
            }
            .flatMapLatest { relation -> Single<[Row.Fantasies]> in
            
                if case .mutual(let roomRef) = relation {
                    return Fantasy.Manager.mutualCards(in: roomRef)
                        .map { $0.map { .card($0) } }
                }
                
                return Fantasy.Manager.likedCards(of: u)
                    .map { $0.map { .sneakPeek($0) } }
                
            }
            .map { (fantasiesRow) in
                
                var res = [("basic", [Row.basic(u.bio.name, u.subscription.isSubscribed)])]
                 
                 if let x = u.bio.about {
                     res.append( ("about", [.about(x, u.bio.sexuality)]) )
                 }
                 
                 var bioSection: (String, [Row]) = ("bio", [])
                 
                 bioSection.1.append(.bio(R.image.profileBirthday()!, "\(u.bio.yearsOld) years"))
                 
                 if let x = u.community.value?.name {
                     bioSection.1.append( .bio(R.image.profileLocation()!, x) )
                 }
                 
                 bioSection.1.append( .bio(R.image.profileSexuality()!, "\(u.bio.sexuality.rawValue) \(u.bio.gender.pretty)") )
                 bioSection.1.append( .bio(R.image.profileRelationships()!, u.bio.relationshipStatus.pretty) )
                 
                 if let x = u.bio.expirience {
                     bioSection.1.append( .bio(R.image.profileExpirience()!, x.description) )
                 }
                
                 if u.bio.lookingFor.count > 0 {
                     bioSection.1.append( .bio(R.image.profileLookingFor()!,
                                               u.bio.lookingFor.map { $0.description }.joined(separator: ", ")) )
                 }
                
                 res.append( bioSection )
                
                 if u.bio.answers.count > 0 {
                     
                     for (key, value) in u.bio.answers {
                         let x = Row.answer(q: key, a: value)
                         res.append( (x.identity, [x] ) )
                     }
                     
                 }
                
                if fantasiesRow.count > 0 {
                    res.append( ("fantasies", [.fantasy( fantasiesRow )] ) )
                }
            
                return res
            }
            .asDriver(onErrorJustReturn: [])
        
    }
    
    var likedStikerHidden: Driver<Bool> {
        
        return .just(true)
        
//        return relationshipState.asDriver()
//            .map { maybe in
//                
//                guard let connection = maybe else {
//                    return true
//                }
//                
//                switch connection {
//                case .absent, .iRejected, .iWasRejected, .sameUser, .incomming(_):
//                    return true
//                    
//                case .outgoing(_), .mutual(_):
//                    return false
//                }
//                
//            }
    }
    
    var relationLabel: Driver<String> {
        return relationshipState.asDriver().notNil()
            .map { x in
                switch x {
                case .sameUser:     return ""
                case .absent:       return "No relation so far"
                case .incomming(_): return "User liked you"
                    
                case .outgoing(let x, _):
                    let str = x.map({ $0.rawValue }).joined(separator: ", ")
                    return "You \(str) this user"
                    
                case .iRejected:    return "You rejected user"
                case .iWasRejected: return "You were rejected"
                case .mutual:       return "You both liked each other"
                }
        }
    }
    
    var relationActions: Driver<[ RelationAction ]> {
        return relationshipState.asDriver()
            .map { x in
                switch x {
                case .absent?:
                    return [
                        .init(descriptior: .imageButton(R.image.profileActionLike()!),
                              action: self.initiateLike),
                        .init(descriptior: .imageButton(R.image.profileActionMessage()!),
                              action: self.initiateMessage)
                    ]
                    
                case .incomming(_, let room)?:
                    return [
                        .init(descriptior: .actionSheetOption("Accept invite"),
                              action: self.likeBack),
                        .init(descriptior: .actionSheetOption("Reject invite"),
                              action: self.reject),
                        .init(descriptior: .openRoomButton,
                              action: { self.present(roomRef: room) })
                    ]
                
                case .mutual(let room)?:
                    return [
                        .init(descriptior: .actionSheetOption("Unlike"),
                              action: self.unlike),
                        .init(descriptior: .openRoomButton,
                              action: { self.present(roomRef: room) })
                    ]
                    
                case .outgoing(let types, let room)?: ///waiting for response
                    
                    var res = [ RelationAction(descriptior: .imageButton(R.image.profileActionMessage()!),
                                               action: { self.present(roomRef: room) }) ]
                        
                    if !types.contains(.like) {
                        res.append( .init(descriptior: .imageButton(R.image.profileActionLike()!),
                                          action:self.initiateLike))
                    }
                    
                    return res
                        
                case .iWasRejected?:
                    return [] ///nothing we can do
                    
                case .iRejected?:
                    return [
                        .init(descriptior: .actionSheetOption("Delete Connection"),
                              action: self.unlike)
                    ]
                    
                case .sameUser, .none: return []
                }
            }
        
    }
    
    enum Photo: IdentifiableType, Equatable {
        case nothing
        case url(String)
        case privateStub(Int)
        
        var identity: String {
            if case .url(let x) = self { return x }
            if case .privateStub(_) = self { return "private stub" }
            
            return "nothing"
        }
        
        static func fromPhotos(public: [FantasyApp.Photo],
                               private: [FantasyApp.Photo],
                               includePrivate: Bool = false) -> [Photo] {
            
            guard `public`.count > 0 else { return [.nothing] }
            
            var showPhotos = `public`
            if includePrivate {
                showPhotos.append(contentsOf: `private`)
            }
            
            var res: [Photo] = showPhotos.map { .url($0.url) }
            
            if !includePrivate {
                res.append( .privateStub(`private`.count) )
            }
            
            return res
        }
        
    }
    
    struct RelationAction {
        
        let descriptior: Descriptior
        let action: () -> Void
        
        enum Descriptior {
            case imageButton(UIImage)
            case openRoomButton
            case actionSheetOption(String)
        }
        
    }
    
    enum Row: IdentifiableType, Equatable {
        case basic(String, Bool)
        case about(String, Sexuality)
        case bio(UIImage, String)
        case fantasy([Fantasies])
        case answer(q: String, a: String)
        
        var identity: String {
            switch self {
            case .basic(let x):         return "basic \(x)"
            case .about(let x):         return "about \(x)"
            case .bio(_, let y):        return "bio \(y)"
            case .fantasy(let x):
                if case .card(_)? = x.first {
                    return "fantasy cards"
                }
                
                return "fantasy sneakPeek"
                
            case .answer(let q, let a): return "answer \(q), \(a)"
                
            }
        }
        
        enum Fantasies: Equatable {
            case card(Fantasy.Card)
            case sneakPeek(Fantasy.Request.LikedCards.SneakPeek)
        }
    }


    var registeredDateText: Driver<String> {
        guard let date = user.createdAt else {
            return Driver.just("")
        }

        let s = date.toRegisteredDateString()
        return Driver.just("Registered \(s)")
    }

    var userIdText: Driver<String> {

        var id = ""

        #if ADHOC || DEBUG
          id = user.id
        #endif

        return Driver.just(id)
    }
}

struct UserProfileViewModel : MVVM_ViewModel {
    
    fileprivate let user: User
    fileprivate let relationshipState = BehaviorRelay<Connection?>(value: nil)
    let bottomActionAvailable: Bool
    
    init(router: UserProfileRouter, user: User, bottomActionsAvailable: Bool = true) {
        self.router = router
        self.user = user
        self.bottomActionAvailable = bottomActionsAvailable

        
        if user.id != User.current!.id {
            ConnectionManager.relationStatus(with: user)
                .asObservable()
                .silentCatch(handler: router.owner)
                .bind(to: relationshipState)
                .disposed(by: bag)
        }
        else {
            relationshipState.accept(.sameUser)
        }
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: UserProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension UserProfileViewModel {
    
    func initiateLike() {
        
        let _ = ConnectionManager.initiate(with: user, type: .like)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .do(onNext: { (x) in
                
                guard case .outgoing(_, let room) = x else {
                    fatalErrorInDebug("Expected connection = .outgoing(_, let room). Received \(x)")
                    return
                }
                
                self.present(roomRef: room)
            })
            .bind(to: relationshipState)
        
    }
    
    func initiateMessage() {
        
        let _ = ConnectionManager.initiate(with: user, type: .message)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .do(onNext: { (x) in
                
                guard case .outgoing(_, let room) = x else {
                    fatalErrorInDebug("Expected connection = .outgoing(_, let room). Received \(x)")
                    return
                }
                
                self.present(roomRef: room)
            })
            .bind(to: relationshipState)
        
    }
    
    func likeBack() {
        
        let _ = ConnectionManager.likeBack(user: user, context: .Profile)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .bind(to: relationshipState)
        
    }
    
    func reject() {
        
        let _ = ConnectionManager.reject(user: user)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .bind(to: relationshipState)
        
    }
    
    func unlike() {
        
        relationshipState.accept( .absent )
        
        let _ = ConnectionManager.deleteConnection(with: user)
            .silentCatch(handler: router.owner)
            .subscribe()
    }
    
    func present(roomRef: RoomRef) {
        
        RoomManager.getRoom(id: roomRef.id)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { room in
                
                guard room.freezeStatus != .frozen else {
                    return self.router.messagePresentable.presentMessage(R.string.localizable.roomFrozenRoomUnreachable())
                }
                
                self.router.present(room: room)
                
            })
            .disposed(by: bag)
        
    }
    
}
