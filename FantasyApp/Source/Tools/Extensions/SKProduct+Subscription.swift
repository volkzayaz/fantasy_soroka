//
//  SKProduct+Subscription.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 07.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation
import SwiftyStoreKit

extension SKProduct {
    
    var subscriptionPeriodDuration: String {
        guard let subscriptionPeriod = subscriptionPeriod else { return "" }
            
        switch subscriptionPeriod.unit {
        case .day: return subscriptionPeriod.numberOfUnits.countableString(withSingularNoun: "day")
        case .month: return subscriptionPeriod.numberOfUnits.countableString(withSingularNoun: "month")
        case .week: return subscriptionPeriod.numberOfUnits.countableString(withSingularNoun: "week")
        case .year: return subscriptionPeriod.numberOfUnits.countableString(withSingularNoun: "year")
        @unknown default: return ""
        }
    }
    
    var shortSubscriptionPeriodDuration: String {
        guard let subscriptionPeriod = subscriptionPeriod else { return "" }
            
        switch subscriptionPeriod.unit {
        case .day: return "\(subscriptionPeriod.numberOfUnits)d"
        case .month: return "\(subscriptionPeriod.numberOfUnits)m"
        case .week: return "\(subscriptionPeriod.numberOfUnits)w"
        case .year: return "\(subscriptionPeriod.numberOfUnits)y"
        @unknown default: return ""
        }
    }
    
    var subscriptionDailyPrice: NSDecimalNumber? {
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }
        
        var divider: Int = subscriptionPeriod.numberOfUnits
        switch subscriptionPeriod.unit {
        case .day: divider *= 1
        case .month: divider *= 30
        case .week: divider *= 7
        case .year: divider *= 365
        @unknown default: return nil
        }
        
        return price.dividing(by: NSDecimalNumber(integerLiteral: divider))
    }
    
    var subscriptionDailyPayment: String {
        guard let dailyPrice = subscriptionDailyPrice else { return "" }
        
        let formatter = SKProduct.formatter
        formatter.locale = priceLocale
        
        let dailyCharge = formatter.string(from: dailyPrice) ?? ""
        return R.string.localizable.subscriptionDailyCharge(dailyCharge)
    }
}
