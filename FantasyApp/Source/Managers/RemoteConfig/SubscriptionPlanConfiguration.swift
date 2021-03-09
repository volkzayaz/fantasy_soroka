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
    case special
}

struct SubscriptionPlanConfiguration: Decodable {
    
    let productId: String
    let baseProductId: String?
    let type: SubscriptionPlanType
    let buttonTitle: String?
    let position: Int?
    
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
        case .special:
            return R.string.localizable.subscriptionSpecialPayment(product.localizedPrice, product.subscriptionPeriodDuration)
        }
    }
    
    func productDetails(product: SKProduct) -> String {
        R.string.localizable.subscriptionSpecialBaseProductDetails(product.localizedPrice, product.subscriptionDailyPayment)
    }
    
    func details(product: SKProduct, baseProduct: SKProduct?) -> String {
        switch type {
        case .regular:
            return R.string.localizable.subscriptionRegularDetails(product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment)
        case .trial:
            return R.string.localizable.subscriptionTrialDetails(title(product: product), product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment)
        case .special:
            let baseProductDetails = baseProduct.map { productDetails(product: $0) } ?? ""
            return R.string.localizable.subscriptionSpecialDetails(product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment, baseProductDetails)
        }
    }
    
    func description(product: SKProduct, baseProduct: SKProduct?) -> String {
        switch type {
        case .regular:
            return R.string.localizable.subscriptionRegularDescription(title(product: product), product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment)
        case .trial:
            return R.string.localizable.subscriptionTrialDescription(title(product: product), product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment)
        case .special:
            let baseProductDetails = baseProduct.map { productDetails(product: $0) } ?? ""
            return R.string.localizable.subscriptionSpecialDescription(title(product: product), product.localizedPrice, product.subscriptionPeriodDuration, product.subscriptionDailyPayment, baseProductDetails)
        }
    }
    
    func sticker(product: SKProduct, baseProduct: SKProduct?) -> String? {
        switch type {
        case .regular:
            return nil
        case .trial:
            return R.string.localizable.subscriptionTrialSticker()
        case .special:
            if let baseProduct = baseProduct, let dailyPrice = product.subscriptionDailyPrice, let baseDailyPrice = baseProduct.subscriptionDailyPrice {
                let discount = Int(round(100 - dailyPrice.dividing(by: baseDailyPrice).multiplying(by: 100).doubleValue))
                return R.string.localizable.subscriptionSpecialSticker(discount)
            } else {
                return nil
            }
        }
    }
}
