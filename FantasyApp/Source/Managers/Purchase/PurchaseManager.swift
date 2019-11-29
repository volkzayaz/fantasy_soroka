//
//  PurchaseManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/21/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStoreKit

enum PurchaseManager {}

extension PurchaseManager {
    
    static func purhcase(collection: Fantasy.Collection) -> Single< Void > {
        
        guard let pid = collection.productId else {
            fatalErrorInDebug("Can't purchase collection without productID")
            return .just( () )
        }
        
        return SwiftyStoreKit.rx_purchase(product: pid)
            .flatMap { _ in SwiftyStoreKit.rx_fetchReceipt(forceRefresh: false) }
            .flatMap { x in User.Request.PurchaseCollection(collection: collection, recieptData: x).rx.request }
            .map { _ in }
        
    }
    
    static func restorePurchases() -> Single<User.Subscription> {
        
        return Single.deferred({
            
            guard let _ = PFUser.current()?.sessionToken else {
                return Single.error( FantasyError.unauthorized )
            }
            
            return self.sendRecipeToServer(forceRefresh: true)
            
        })
        
    }
    
    static func purhcaseSubscription() -> Single<User.Subscription> {
        
        let goldPlanProductId = immutableNonPersistentState.subscriptionProductID
        
        return SwiftyStoreKit.rx_purchase(product: goldPlanProductId)
            .flatMap { x in
                return self.sendRecipeToServer(forceRefresh: false,
                                               transactionToFinish: x.transaction)
            }
    }
    
    static func fetchSubscriptionStatus() -> Single<User.Subscription> {
        return User.Request.SubscriptionStatus().rx.request
    }
    
}

extension PurchaseManager {

    static func completeTransacions() {

        SwiftyStoreKit.completeTransactions(atomically: false) { (purchasess) in

            guard let _ = PFUser.current()?.sessionToken else {
                ////Any time transaction update happens (renew, cancel, change plan)
                ////user might be logged out
                ////For now we ignore such behaviours
                return
            }
            
            let _ =
            self.sendRecipeToServer(forceRefresh: false)
                .asObservable()
                .take(1)
                .do(onNext: { _ in
                    purchasess.filter { $0.needsFinishTransaction }
                              .map { $0.transaction }
                              .forEach(SwiftyStoreKit.finishTransaction)
                })
                .subscribe()

        }
    }
    
    fileprivate static func sendRecipeToServer(forceRefresh: Bool,
                                               transactionToFinish: PaymentTransaction? = nil) -> Single<User.Subscription> {
        
        return SwiftyStoreKit.rx_fetchReceipt(forceRefresh: forceRefresh)
            .flatMap { reciept in
                return User.Request.SendReceipt(recieptData: reciept).rx.request
            }
            .do(onSuccess: { (subscription) in
                
                if let t = transactionToFinish {
                    SwiftyStoreKit.finishTransaction(t)
                }
                
                var u = User.current!
                u.subscription = subscription
                Dispatcher.dispatch(action: SetUser(user: u))
                
            })
    
    }
    
}

extension SwiftyStoreKit {
    
    public class func rx_validateReceipt(forceRefresh: Bool) -> Maybe<Data> {
        return Maybe.create(subscribe: { (subscriber) -> Disposable in

            let v = AppleReceiptValidator(service: .sandbox, sharedSecret: "a95cb2f1957d470c8837076a0359e901")

            SwiftyStoreKit.verifyReceipt(using: v,
                forceRefresh: forceRefresh,
                completion: { (result) in

                    switch result {

                    case .error(let error):
                        subscriber(.error(error))

                    case .success(let receiptData):

//                        let res = SwiftyStoreKit.verifyPurchase(productId: "asd", inReceipt: receiptData) .verifySubscription(ofType: .autoRenewable,
//                                                                    productId: Subscription.Plan.oneMonthTrial.productIdentifier,
//                                                                    inReceipt: receiptData)

                        //print(res)

                        print(receiptData)

                        subscriber(.success(Data()))
                    }

            })

            return Disposables.create()
        })
    }
    
    public class func rx_fetchReceipt(forceRefresh: Bool) -> Single<Data> {
        return Single.create(subscribe: { (subscriber) -> Disposable in
            
            SwiftyStoreKit.fetchReceipt(
                                         forceRefresh: forceRefresh,
                                         completion: { (result) in
                
                switch result {
                    
                case .error(let error):
                    subscriber(.error(error))
                    
                case .success(let receiptData):
                    
                    subscriber(.success(receiptData))
                }
                
            })
            
            return Disposables.create()
        })
    }
 
    public class func rx_purchase(product: String) -> Single<PurchaseDetails> {
        
        return Single.create(subscribe: { (subscriber) -> Disposable in
            
            SwiftyStoreKit.purchaseProduct(product, atomically: false) { (res) in
                
                switch res {
                    
                case .error(let error):
                    subscriber(.error(error))
                    
                case .success(let data):
                    subscriber(.success(data))
                    
                }
                
            }
            
            return Disposables.create()
        })
    }
    
    public class func rx_productDetails(product: String) -> Single<SKProduct> {
        
        return Single.create(subscribe: { (subscriber) -> Disposable in
            
            SwiftyStoreKit.retrieveProductsInfo([product]) { (res: RetrieveResults) in
                
                if let e = res.error {
                    return subscriber(.error(e))
                }
                
                subscriber(.success( res.retrievedProducts.first! ))
                
            }
            
            return Disposables.create()
        })
    }
    
}
