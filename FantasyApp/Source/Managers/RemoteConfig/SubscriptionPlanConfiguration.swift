//
//  SubscriptionPlanConfiguration.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 08.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation

enum SubscriptionPlanType: String, Decodable {
    case regular
    case trial
    case offer
}

struct SubscriptionPlanConfiguration: Decodable {
    
    let productId: String
    let baseProductId: String?
    let type: SubscriptionPlanType
    let buttonTitle: String?
    let position: Int
    
    var localizedButtonTitle: String {
        if let buttonTitle = buttonTitle {
            return NSLocalizedString(buttonTitle, comment: "")
        } else {
            return R.string.localizable.subscriptionPlanButtonTitle()
        }
    }
    
    func title(product: SKProduct) -> String {
        NSLocalizedString(product.productIdentifier, value: product.localizedTitle, comment: "")
    }
        
    func payment(product: SKProduct) -> String {
        switch type {
        case .regular:
            return R.string.localizable.subscriptionRegularPayment(product.localizedPrice, product.subscriptionPeriodDuration)
        case .trial:
            return R.string.localizable.subscriptionTrialPayment(product.localizedPrice, product.subscriptionPeriodDuration)
        case .offer:
            return R.string.localizable.subscriptionOfferPayment(product.localizedPrice, product.subscriptionPeriodDuration)
        }
    }
    
    func details(product: SKProduct, baseProduct: SKProduct?) -> NSAttributedString {
        switch type {
        case .regular:
            let dailyPayment = product.subscriptionDailyPayment
            let details = R.string.localizable.subscriptionRegularDetails(product.localizedPrice, product.subscriptionPeriodDuration, dailyPayment)
            
            let result = NSMutableAttributedString(string: details)
            if let range = details.range(of: dailyPayment) {
                result.addAttributes([.font : UIFont.boldFont(ofSize: 12)], range: details.nsRange(from: range))
            }
            
            return result
        case .trial:
            let dailyPayment = product.subscriptionDailyPayment
            let baseProductTitle = baseProduct.map { NSLocalizedString($0.productIdentifier, comment: "") } ?? baseProduct?.localizedTitle ?? ""
            let details = R.string.localizable.subscriptionTrialDetails(baseProductTitle, product.localizedPrice, product.subscriptionPeriodDuration, dailyPayment)
            
            let result = NSMutableAttributedString(string: details)
            if let range = details.range(of: dailyPayment) {
                result.addAttributes([.font : UIFont.boldFont(ofSize: 12)], range: details.nsRange(from: range))
            }
            
            return result
        case .offer:
            let dailyPayment = product.subscriptionDailyPayment
            let baseProductDetails = R.string.localizable.subscriptionOfferBaseProductDetails(baseProduct?.localizedPrice ?? "", baseProduct?.subscriptionDailyPayment ?? "")
            let details = R.string.localizable.subscriptionOfferDetails(product.localizedPrice, product.subscriptionPeriodDuration, dailyPayment, baseProductDetails)
            
            let result = NSMutableAttributedString(string: details)
            if let range = details.range(of: dailyPayment) {
                result.addAttributes([.font : UIFont.boldFont(ofSize: 12)], range: details.nsRange(from: range))
            }
            
            if let range = details.range(of: baseProductDetails) {
                result.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue], range: details.nsRange(from: range))
            }
            
            return result
        }
    }
    
    func sticker(product: SKProduct, baseProduct: SKProduct?) -> String? {
        switch type {
        case .regular:
            return nil
        case .trial:
            return R.string.localizable.subscriptionTrialSticker()
        case .offer:
            if let baseProduct = baseProduct, let dailyPrice = product.subscriptionDailyPrice, let baseDailyPrice = baseProduct.subscriptionDailyPrice {
                let discount = Int(round(100 - dailyPrice.dividing(by: baseDailyPrice).multiplying(by: 100).doubleValue))
                return R.string.localizable.subscriptionOfferSticker(discount)
            } else {
                return nil
            }
        }
    }
}
