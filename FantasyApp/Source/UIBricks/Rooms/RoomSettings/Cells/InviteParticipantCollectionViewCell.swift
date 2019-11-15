//
//  InviteParticipantCollectionViewCell.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 11.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class InviteParticipantCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2.0
    }
    
    func setMode(isWaiting: Bool) {
        
        if isWaiting {
        
            imageView.image = R.image.roomLoading()
            
            let animationDuration: CFTimeInterval = 1.1
            let linearCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.duration = animationDuration
            animation.timingFunction = linearCurve
            animation.isRemovedOnCompletion = false
            animation.repeatCount = Float.greatestFiniteMagnitude
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.autoreverses = false
            imageView.layer.add(animation, forKey: "rotate")
            
            titleLabel.text = "Waiting"
            
        }
        else {
            
            imageView.layer.removeAllAnimations()
            imageView.image = R.image.invite()

            titleLabel.text = "Add"
            
        }
        
    }
    
}

private extension InviteParticipantCollectionViewCell {
    func configure() {
        backgroundColor = .clear
        imageView.backgroundColor = .fantasyGrey
        imageView.contentMode = .center
        titleLabel.textColor = .fantasyPink
        titleLabel.font = .boldFont(ofSize: 16)
        titleLabel.text = R.string.localizable.roomCreationParticipantsAdd()
    }
}

