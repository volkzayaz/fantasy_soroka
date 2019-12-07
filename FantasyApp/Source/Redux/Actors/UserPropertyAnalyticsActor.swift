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

import Amplitude_iOS
import Crashlytics
import Branch

class UserPropertyActor {
    private let bag = DisposeBag()

    init() {
        
        appState.changesOf { $0.currentUser }
            .asObservable().subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { maybeUser in
                
                guard let user = maybeUser else {

                    Amplitude.instance()?.setUserId(nil)
                    Amplitude.instance()?.regenerateDeviceId()
                    
                    return
                }
                
                func applicator<T: NSObject>(value: T?, key: String, i: AMPIdentify) -> AMPIdentify {
                    
                    if let x = value {
                        i.set(key, value: x)
                    }
                    else {
                        i.unset(key)
                    }
                    
                    return i
                }
                
                //!!! can't pass date "Profile Status: Signed Up" : PFUser.current()!.createdAt as NSDate?
                
                let newIdentity =
                    [
                        "Profile Status: Is In Active City": NSNumber(booleanLiteral: user.community.value != nil),
                        "Profile Status: Active City Name": user.community.value?.name as NSString?,
                        
                        "Profile Status: Location" : (user.community.value?.name ?? user.community.lastKnownLocation?.assosiatedTown) as NSString?,
                        
                        
                ]
                .reduce(AMPIdentify()) { (i, tuple) in
                    return applicator(value: tuple.value, key: tuple.key, i: i)
                }
                
                Amplitude.instance()?.setUserId(user.id)
                Amplitude.instance()?.identify(newIdentity)
                
                
                ///user .add for increment operations
                
                ///[[Amplitude instance] setOptOut:YES]; to turn user off from logging. Not sure if we need it
                
//                Amplitude.instance()?.logRevenueV2(AMPRevenue!)
                
                
                
//                Crashlytics.sharedInstance().setUserIdentifier(user?.id)
//                Crashlytics.sharedInstance().setUserName(user?.bio.name)
//
//                if let id = user?.id {
//                    Branch.getInstance()?.setIdentity(id)
//                } else {
//                    Branch.getInstance()?.logout()
//                }
                
        }).disposed(by: bag)

        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { (_) in
                
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    
                    print(settings)
                    
                }
                
            })
        
        
        
    }
}
