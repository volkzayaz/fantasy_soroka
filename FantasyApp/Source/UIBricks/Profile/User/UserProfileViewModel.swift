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

extension UserProfileViewModel {
    
    var photos: [Photo] {
        
        guard user.profile.bio.photos.public.count > 0 else {
            return [.nothing]
        }
        
        return user.profile.bio.photos.public.map { .url($0) }
    }

    var sections: [Section] {
        
        var res = [Section.basic(user.profile.bio.name + " \(user.profile.bio.birthday)")]
        
        if let x = user.profile.about {
            res.append( .about(x) )
        }
        
        res.append( .extended( [
            "Gender - " + user.profile.bio.gender.rawValue,
            "Relationship - " + user.profile.bio.relationshipStatus.description,
            "Sexuality - " + user.profile.bio.sexuality.rawValue
        ]))
        
        if user.fantasies.liked.count > 0 {
            
            let simpleFantasies = user.fantasies.liked
                .map { $0.name }
                .joined(separator: ", ")
            
            
            res.append( .fantasy( "Fantasies: " + simpleFantasies  ) )
        }
        
        return res
    }
    
    enum Photo {
        case nothing
        case url(String)
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
    
    init(router: UserProfileRouter, user: User) {
        self.router = router
        self.user = user
        
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
    
    let router: UserProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension UserProfileViewModel {
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
