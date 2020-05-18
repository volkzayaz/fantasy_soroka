//
//  RoomTutorialViewController.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 5/17/20.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class RoomTutorialViewController: UIViewController {
    
    @IBOutlet private var firstLabel: UILabel! {
        didSet {
            var strokeTextAttributes: [NSAttributedString.Key: Any] = [
                .strokeColor: UIColor.white,
                .foregroundColor: UIColor.white,
                .strokeWidth: -4.0,
                .font: UIFont.systemFont(ofSize: 50, weight: .heavy),
            ]
            let attrText = NSMutableAttributedString(string: R.string.localizable.roomsOnboardingInviteParnerPart1(), attributes: strokeTextAttributes)
            strokeTextAttributes[.foregroundColor] = UIColor.clear
            let secondPartAttrStr = NSAttributedString(string: "\n\(R.string.localizable.roomsOnboardingInviteParnerPart2())", attributes: strokeTextAttributes)
            attrText.append(secondPartAttrStr)

            firstLabel.numberOfLines = 0
            firstLabel.attributedText = attrText
        }
    }
    
    @IBOutlet private var secondLabel: UILabel! {
        didSet {
            var strokeTextAttributes: [NSAttributedString.Key: Any] = [
                .strokeColor: UIColor.white,
                .foregroundColor: UIColor.white,
                .strokeWidth: -4.0,
                .font: UIFont.systemFont(ofSize: 50, weight: .heavy),
            ]
            let attrText = NSMutableAttributedString(string: R.string.localizable.roomsOnboardingMutualFantasiesPart1(), attributes: strokeTextAttributes)
            strokeTextAttributes[.foregroundColor] = UIColor.clear
            let secondPartAttrStr = NSAttributedString(string: "\n\(R.string.localizable.roomsOnboardingMutualFantasiesPart2())", attributes: strokeTextAttributes)
            attrText.append(secondPartAttrStr)

            secondLabel.numberOfLines = 0
            secondLabel.attributedText = attrText
        }
    }
    
    @IBOutlet private var thirdLabel: UILabel! {
        didSet {
            var strokeTextAttributes: [NSAttributedString.Key: Any] = [
                .strokeColor: UIColor.white,
                .foregroundColor: UIColor.white,
                .strokeWidth: -4.0,
                .font: UIFont.systemFont(ofSize: 50, weight: .heavy),
            ]
            let attrText = NSMutableAttributedString(string: R.string.localizable.roomsOnboardingPlayPart1(), attributes: strokeTextAttributes)
            strokeTextAttributes[.foregroundColor] = UIColor.clear
            let secondPartAttrStr = NSAttributedString(string: "\n\(R.string.localizable.roomsOnboardingPlayPart())", attributes: strokeTextAttributes)
            attrText.append(secondPartAttrStr)

            thirdLabel.numberOfLines = 0
            thirdLabel.attributedText = attrText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
