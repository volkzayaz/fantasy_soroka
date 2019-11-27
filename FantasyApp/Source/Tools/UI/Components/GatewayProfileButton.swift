//
//  GetewayProfileButton.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 27.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class GatewayProfileButton: UIControl {
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var label: UILabel!

    public override var isHighlighted: Bool {
        didSet {
            setupBackgroundColor()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            setupBackgroundColor()
        }
    }

    func setupBackgroundColor() {
        image.alpha = (isEnabled && !isHighlighted) ? 1.0 : 0.3
        label.alpha = (isEnabled && !isHighlighted) ? 1.0 : 0.3
    }
}
