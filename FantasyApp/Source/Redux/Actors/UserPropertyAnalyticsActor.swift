//
//  UserPropertyAnalyticsActor.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 13.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Amplitude_iOS
import Crashlytics
import Branch

var _AnalyticsHackyTown: String? = nil

class UserPropertyActor {
    private let bag = DisposeBag()

    init() {
        
        func applicator<T: NSObject>(value: T?, key: String, i: AMPIdentify) -> AMPIdentify {
            
            if let x = value {
                i.set(key, value: x)
            }
            else {
                i.unset(key)
            }
            
            return i
        }
        
        ///Generic User Properties
        appState.changesOf { $0.currentUser }
            .asObservable().observeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { maybeUser in
                
                ///Crashlytics
                Crashlytics.sharedInstance().setUserIdentifier(maybeUser?.id)
                Crashlytics.sharedInstance().setUserName(maybeUser?.bio.name)

                ///Barnch
                if let id = maybeUser?.id {
                    Branch.getInstance()?.setIdentity(id)
                } else {
                    Branch.getInstance()?.logout()
                }
                
                ///Amplitude
                guard let user = maybeUser else {

                    Amplitude.instance()?.setUserId(nil)
                    Amplitude.instance()?.regenerateDeviceId()
                    
                    return
                }
                
                //!!! can't pass date "Profile Status: Signed Up" : PFUser.current()!.createdAt as NSDate?
                
                let newIdentity =
                    [
                        "Profile Status: Active City Name": user.community.value?.name as NSString?,
                        
                        "Profile Status: Signed Up" : PFUser.current()?.createdAt?.toAnalyticsTime() as NSString?,
                        
                        "Profile Trait: Sex" : user.bio.gender.rawValue as NSString?,
                        "Profile Trait: Age" : NSNumber(integerLiteral: user.bio.birthday.distance(from: Date(), in: .year)),
                        "Profile Trait: Sexuality" : user.bio.sexuality.rawValue as NSString?,
                        "Profile Trait: Realtionship" : user.bio.relationshipStatus.analyticsTuple.0 as NSString?,
                        "Profile Trait: Partner's Sex" : user.bio.relationshipStatus.analyticsTuple.1 as NSString?,
                        
                ]
                .reduce(AMPIdentify()) { (i, tuple) in
                    return applicator(value: tuple.value, key: tuple.key, i: i)
                }
                
                Amplitude.instance()?.setUserId(user.id)
                Amplitude.instance()?.identify(newIdentity)
                
                
                ///user .add for increment operations
                
                ///[[Amplitude instance] setOptOut:YES]; to turn user off from logging. Not sure if we need it
                
//                Amplitude.instance()?.logRevenueV2(AMPRevenue!)
                
                
                
        }).disposed(by: bag)

        ///Physical Location
        appState.changesOf { $0.currentUser?.community.lastKnownLocation }
            .skip(1)
            .asObservable()
            .observeOn(SerialDispatchQueueScheduler(qos: .background))
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                switch (lhs, rhs) {
                    
                case (let left?, let right?):
                    return left.clLocation.distance(from: right.clLocation) < 5000 //5km
                    
                default: return false
                    
                }
            })
            .flatMapLatest { maybeLastKnownLocation -> Single<String?> in
                
                guard let lastKnownLocation = maybeLastKnownLocation else {
                    return .just(nil)
                }
                
                return CLGeocoder().rx.city(near: lastKnownLocation.clLocation)

            }
            .subscribe(onNext: { maybePhysicalCity in
                
                let i = applicator(value: maybePhysicalCity as NSString?,
                                   key: "Profile Status: Location",
                                   i: AMPIdentify())
                
                Amplitude.instance()?.identify(i)
                
            })
            .disposed(by: bag)
        
        ///is in active city
        appState.changesOf { $0.currentUser?.community }
            .asObservable()
            .observeOn(SerialDispatchQueueScheduler(qos: .background))
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                switch (lhs, rhs) {

                case (let left?, let right?):
                    guard let x = left.lastKnownLocation?.clLocation,
                          let y = right.lastKnownLocation?.clLocation else {
                        return false
                    }
                    
                    return x.distance(from: y) < 5000 //5km

                default: return true

                }
            })
            .flatMapLatest { maybeCommunity -> Single<Bool?> in

                guard let community = maybeCommunity,
                      let location = community.lastKnownLocation?.clLocation else {
                    return .just(nil)
                }
            
                if community.changePolicy == .locationBased {
                    return .just( community.value != nil )
                }
                
                return CommunityManager.communities(near: location)
                    .map { $0.count > 0 }

            }
            .subscribe(onNext: { maybeBool in

                let i = applicator(value: maybeBool == nil ? nil: NSNumber(booleanLiteral: maybeBool!),
                                   key: "Profile Status: Is In Active City",
                                   i: AMPIdentify())

                Amplitude.instance()?.identify(i)

            })
            .disposed(by: bag)
        
        ///Push status
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { (_) in
                
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        
                    Amplitude.instance()?.setUserProperties([
                        "Profile Status: Push": Analytics.PushStatus(settings: settings).rawValue
                    ])
                    
                }
                
            })
            .disposed(by: bag)
            
    }
}
