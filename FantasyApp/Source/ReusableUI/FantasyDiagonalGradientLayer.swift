//
//  FantasyDiagonalGradientLayer.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 12.01.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit

class FantasyDiagonalGradientLayer: CAGradientLayer {

    override init() {
        super.init()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}

private extension FantasyDiagonalGradientLayer {
    
    func setUp() {
        let color1 = UIColor(fromHex: 0xD855B3)
        let color2 = UIColor(fromHex: 0xB281E7)
        let color3 = UIColor(fromHex: 0x7CBFD7)

        colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        locations = [0, 0.5, 1]
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 1, y: 0)
    }
}
