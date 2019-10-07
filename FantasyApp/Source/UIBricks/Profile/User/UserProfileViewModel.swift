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
        
        let photosDriver: Driver<([FantasyApp.Photo], [FantasyApp.Photo])>
        
        if user.bio.photos.public.isReal {
            photosDriver = .just( (user.bio.photos.public.images, user.bio.photos.private.images) )
        }
        else {
            photosDriver = UserManager.images(of: user)
                    .trackView(viewIndicator: indicator)
                    .silentCatch()
                    .asDriver(onErrorJustReturn: ([], []))
        }
        
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

    var sections: [Section] {
        
        var res = [Section.basic(user.bio.name + " \(user.bio.birthday)")]
        
        if let x = user.bio.about {
            res.append( .about(x) )
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
                res.append( .extended( [key, value] ) )
            }
            
        }
        
        if user.fantasies.liked.count > 0 {
            
            let simpleFantasies = user.fantasies.liked
                .map { $0.text }
                .joined(separator: "; ")
            
            
            res.append( .fantasy( "Fantasies: " + simpleFantasies  ) )
        }
        
        return res
    }
    
    var relationLabel: Driver<String> {
        return relationshipState.asDriver().notNil()
            .map { x in
                switch x {
                case .sameUser:     return ""
                case .absent:       return "No relation so far"
                case .incomming(_): return "User liked you"
                case .outgoing(_):  return "You liked this user"
                case .iRejected:    return "You rejected user"
                case .iWasRejected: return "You were rejected"
                case .mutual:       return "You both liked each other"
                }
        }
    }
    
    var relationActionTitle: Driver<String> {
        return relationshipState.asDriver()
            .map { x -> String in
                switch x {
                case .sameUser:             return ""
                case .absent?:              return "Like user"
                case .incomming(_)?:        return "Decide"
                case .outgoing(_)?:         return ""
                case .iWasRejected?:        return ""
                case .iRejected?:           return "Unreject"
                case .mutual?:              return "Unlike"
                case .none:                 return ""
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
    
    enum Section {
        case basic(String)
        case about(String)
        case extended([String])
        case fantasy(String)
    }
    
}

struct UserProfileViewModel : MVVM_ViewModel {
    
    fileprivate let user: User
    fileprivate let relationshipState = BehaviorRelay<Connection?>(value: nil)
    
    init(router: UserProfileRouter, user: User) {
        self.router = router
        self.user = user
        
        if user != User.current! {
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
    
    func relationAction() {
        
        if case .absent? = relationshipState.value {
        
            relationshipState.accept( .outgoing(request: .like))
            
            let _ = ConnectionManager.like(user: user)
                .do(onError: { [weak r = relationshipState] (er) in
                    r?.accept(.absent)
                })
                .silentCatch(handler: router.owner)
                .subscribe()
            
            return
        }
        
        if case .incomming(_)? = relationshipState.value {
            
            router.owner.showDialog(title: "Pick Action", text: "", style: .alert,
                                    actions: [
                                        UIAlertAction(title: "Like",
                                                      style: .default,
                                                      handler: { (_) in
                                                        self.likeBack()
                                        }),
                                        UIAlertAction(title: "Reject",
                                                      style: .default,
                                                      handler: { (_) in
                                                        self.reject()
                                        }),
                                        UIAlertAction(title: "Cancel",
                                                      style: .cancel,
                                                      handler: nil),
                ])
            return
        }
        
        if case .mutual? = relationshipState.value {
            
            relationshipState.accept( .absent )
            
            let _ = ConnectionManager.deleteConnection(with: user)
                .do(onError: { [weak r = relationshipState] (er) in
                    r?.accept(.absent)
                })
                .silentCatch(handler: router.owner)
                .subscribe()
            
        }
 
        if case .iRejected? = relationshipState.value {
            
            relationshipState.accept( .absent )
            
            let _ = ConnectionManager.deleteConnection(with: user)
                .do(onError: { [weak r = relationshipState] (er) in
                    r?.accept(.absent)
                })
                .silentCatch(handler: router.owner)
                .subscribe()
            
        }
        
    }
    
    private func likeBack() {
        let copy = relationshipState.value
        
        relationshipState.accept( .mutual )
        
        let _ = ConnectionManager.likeBack(user: user)
            .do(onError: { [weak r = relationshipState] (er) in
                r?.accept(copy)
            })
            .silentCatch(handler: router.owner)
            .subscribe()
        
        return
    }
    
    private func reject() {
        let copy = relationshipState.value
        
        relationshipState.accept( .iRejected )
        
        let _ = ConnectionManager.reject(user: user)
            .do(onError: { [weak r = relationshipState] (er) in
                r?.accept(copy)
            })
            .silentCatch(handler: router.owner)
            .subscribe()
        
        return
    }
    
}
