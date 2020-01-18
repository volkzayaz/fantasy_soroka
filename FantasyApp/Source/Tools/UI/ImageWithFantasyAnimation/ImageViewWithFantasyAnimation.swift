//
//  ImageViewWithFantasyAnimation.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 18.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class ImageViewWithFantasyAnimation: UIView {

    @IBInspectable var imageName: String = ""

    let gradientImage: UIImageView = UIImageView.init(image: R.image.loader_gradient()!)
    let fantasyMask = CALayer()
    let gradientViewWidth: CGFloat = 400.0
    var isAnimation: Bool = false

    var delta: CGFloat {
//        return bounds.size.width
        return 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        gradientImage.contentMode = .scaleAspectFill
        addSubview(gradientImage)

        fantasyMask.contents = UIImage(named: imageName)?.cgImage as Any
        layer.mask = fantasyMask
        layer.masksToBounds = true
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        fantasyMask.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        gradientImage.frame = CGRect(x: delta - gradientViewWidth, y: -2, width: gradientViewWidth, height: rect.size.height)
    }

    @objc private func animateLogo() {

        let f = frame

        UIView.animate(withDuration: 2.0, animations: {
            self.gradientImage.frame = CGRect(x: 0, y: 0, width: self.gradientViewWidth, height: f.size.height)
        }) { _ in
            UIView.animate(withDuration: 2.0, animations: {
                self.gradientImage.frame = CGRect(x: self.delta - self.gradientViewWidth, y: 0, width: self.gradientViewWidth, height: f.size.height)
            }) {_ in
                self.isAnimation = false
            }
        }
    }

}

//MARK:- Animation Control

extension ImageViewWithFantasyAnimation {
    public func startAnimation() {

        guard !isAnimation else { return }

        isAnimation = true
        animateLogo()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
