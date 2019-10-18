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

    var sections: Driver<[Section]> {
        
        var res = [Section.basic(user.bio.name + ", \(Calendar.current.dateComponents([.year], from: user.bio.birthday, to: Date()).year!)")]
        
        if let x = user.bio.about {
            res.append( .about(x, user.bio.sexuality) )
        }
        
        if user.subscription.isSubscribed {
            res.append( .basic("This user has golden membership") )
        }
        
        var bioSection = [
            "Gender - " + user.bio.gender.rawValue,
            "Relationship - " + user.bio.relationshipStatus.description,
            "Sexuality - " + user.bio.sexuality.rawValue
        ]
        
        if let l = user.bio.lookingFor {
            bioSection.append("Looking for: \(l)")
        }
        
        if let x = user.bio.expirience {
            bioSection.append("Expirience: \(x)")
        }
        
        res.append( .extended( bioSection ))
       
        if user.bio.answers.count > 0 {
            
            for (key, value) in user.bio.answers {
                res.append( .answer(q: key, a: value ) )
            }
            
        }
        
        return Fantasy.Manager.mutualCards(with: user)
            .map { (collection) -> [Section] in
                
                if collection.count > 0 {
                    
                    let simpleFantasies = collection
                        .map { $0.description.appending(" = \($0.cards.count) mutual cards") }
                        .joined(separator: "; ")
                    
                    res.append( .fantasy( "Fantasies: " + simpleFantasies  ) )
                }
            
                return res
            }
            .asDriver(onErrorJustReturn: res)
            .startWith(res)
        
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
    
    var relationActions: Driver<[ (String, () -> Void) ]> {
        return relationshipState.asDriver()
            .map { x in
                switch x {
                case .absent?:
                    return [
                        ("Like User", self.initiateLike),
                        ("Message User", self.initiateMessage)
                    ]
                    
                case .incomming(_, let room)?:
                    return [
                        ("Accept", self.likeBack),
                        ("Reject", self.reject),
                        ("Open Room", { self.present(room: room) } )
                    ]
                
                case .mutual(let room)?:
                    return [
                        ("Unlike", self.unlike),
                        ("Open Room", { self.present(room: room) } )
                    ]
                    
                case .outgoing(let types, let room)?: ///waiting for response
                    
                    var res = [ ("Message", { self.present(room: room) } ) ]
                    
                    if !types.contains(.like) {
                        res.append(("Like", self.initiateLike ))
                    }
                    
                    return res
                        
                case .iWasRejected?:
                    return [] ///nothing we can do
                    
                case .iRejected?:
                    return [
                        ("Delete Connection", self.unlike )
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
    
    enum Section: IdentifiableType, Equatable {
        case basic(String)
        case about(String, Sexuality)
        case extended([String])
        case fantasy(String)
        case answer(q: String, a: String)
        
        var identity: String {
            switch self {
            case .basic(let x): return "basic \(x)"
            case .about(let x): return "about \(x)"
            case .extended(let x): return "extended \(x)"
            case .fantasy(let x): return "fantasy \(x)"
            case .answer(let q, let a): return "answer \(q), \(a)"
                
            }
        }
    }
    
}

struct UserProfileViewModel : MVVM_ViewModel {
    
    fileprivate let user: User
    fileprivate let relationshipState = BehaviorRelay<Connection?>(value: nil)
    
    init(router: UserProfileRouter, user: User) {
        self.router = router
        self.user = user
        
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
                
                self.present(room: room)
            })
            .bind(to: relationshipState)
        
    }
    
    func likeBack() {
        
        let _ = ConnectionManager.likeBack(user: user)
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
    
    func present(room: Chat.Room) {
        router.present(room: room)
    }
    
}
