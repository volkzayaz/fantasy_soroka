//
//  FantasyHorizontalGradientLayer.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 26.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class FantasyHorizontalGradientLayer: CAGradientLayer {

    override init() {
        super.init()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}

private extension FantasyHorizontalGradientLayer {
    
    func setUp() {
        let color1 = UIColor(fromHex: 0xF0398B)
        let color2 = UIColor(fromHex: 0xB77AE9)
        let color3 = UIColor(fromHex: 0x54EECB)

        colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        locations = [0, 0.6, 1]
        startPoint = CGPoint(x: 0.25, y: 0)
        endPoint = CGPoint(x: 1, y: 0.4)
    }
}
