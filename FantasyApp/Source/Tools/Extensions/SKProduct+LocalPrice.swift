//
//  SKProduct+LocalPrice.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 20.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

extension SKProduct {
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    var localizedPrice: String {
        if self.price == 0.00 {
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale

            guard let formattedPrice = formatter.string(from: self.price) else {
                return "Unknown Price"
            }

            return formattedPrice
        }
    }
}
