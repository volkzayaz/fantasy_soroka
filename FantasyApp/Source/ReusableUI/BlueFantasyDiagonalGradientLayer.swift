//
//  BlueFantasyDiagonalGradientLayer.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 12.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class BlueFantasyDiagonalGradientLayer: CAGradientLayer {

    override init() {
        super.init()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}

private extension BlueFantasyDiagonalGradientLayer {
    
    func setUp() {
        let color1 = UIColor(fromHex: 0xA392E3)
        let color2 = UIColor(fromHex: 0x60E0CF)

        colors = [color1.cgColor, color2.cgColor]
        locations = [0, 1]
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 1, y: 0)
    }
}
