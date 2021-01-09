//
//  SubscriptionPlansConfiguration.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 08.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation

struct SubscriptionPlansConfiguration: Decodable {
    
    enum Style: Int, Decodable {
        case style1 = 1
        case style2
        case style3
    }
    
    let style: Style
    let plans: [SubscriptionPlanConfiguration]

    static let `default` = SubscriptionPlansConfiguration(style: .style1, plans: [
        SubscriptionPlanConfiguration(productId: "com.fantasyapp.iosclient.iap.premium", baseProductId: nil, type: .regular, buttonTitle: nil, position: 1),
        SubscriptionPlanConfiguration(productId: "com.fantasyapp.iosclient.iap.premium.months3", baseProductId: nil, type: .regular, buttonTitle: nil, position: 1),
        SubscriptionPlanConfiguration(productId: "com.fantasyapp.iosclient.iap.premium.year", baseProductId: nil, type: .regular, buttonTitle: nil, position: 1)])
}
