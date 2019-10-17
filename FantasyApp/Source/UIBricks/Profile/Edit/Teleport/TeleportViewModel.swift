//
//  TeleportViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension TeleportViewModel {
    
    var dataSource: Driver<[SectionModel<String, Data>]> {
        
        return mode.asDriver()
            .flatMapLatest { mode in
                
                return self.data.asDriver().map { data in
                    
                    switch mode {
                    case .countries:
                        return [
                            SectionModel(model: "", items: [Data.location]),
                            SectionModel(model: "", items: data.keys.sorted().reversed().map { Data.country($0) })
                        ]
                        
                    case .communities(let fromCountry):
                        return [
                            SectionModel(model: "", items: [Data.location]),
                            SectionModel(model: "", items: (data[fromCountry] ?? []).map { Data.community($0) })
                        ]
                        
                    }
                    
                }
                
            }
        
    }
    
    enum Data {
        case community(Community)
        case country(String)
        case location
    }
    
    enum Mode {
        case countries
        case communities(fromCountry: String)
    }
    
}

struct TeleportViewModel : MVVM_ViewModel {
    
    fileprivate let mode = BehaviorRelay(value: Mode.countries)
    fileprivate let data = BehaviorRelay<[String: [Community]]>(value: [:])
    
    fileprivate let form: BehaviorRelay<EditProfileForm>
    
    init(router: TeleportRouter, form: BehaviorRelay<EditProfileForm>) {
        self.router = router
        self.form = form
        
        CommunityManager.allCommunities()
            .trackView(viewIndicator: indicator)
            .silentCatch()
            .map { Dictionary(grouping: $0, by: { $0.country }) }
            .bind(to: data)
            .disposed(by: bag)
        
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
    
    let router: TeleportRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension TeleportViewModel {
    
    func selected(data: Data) {
        
        var x = form.value
        
        switch data {
        case .community(let community):
            x.communityChange = User.Community(value: community,
                                               changePolicy: .teleport)
        
        case .location:
            x.communityChange = User.Community(value: nil,
                                               changePolicy: .locationBased)
            
        case .country(let country):
            return mode.accept(.communities(fromCountry: country))
            
        }
        
        form.accept(x)
        router.popBack()
        
    }
    
    func back() {
        
        if case .communities(_) = mode.value {
            return mode.accept(.countries)
        }

        router.popBack()
        
    }
    
}
