//
//  FantasyDeckTutorialSlide.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 15.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyDeckTutorialSlide: UIView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!

    static var instance: FantasyDeckTutorialSlide {
        let slide = Bundle.main.loadNibNamed("FantasyDeckTutorialSlide", owner: self, options: nil)?.first as! FantasyDeckTutorialSlide
        return slide
    }
}
