//
//  PrimaryButton.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Foundation

public class PrimaryButton: UIButton {
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

    public var titleFont: UIFont = .boldFont(ofSize: 16) {
        didSet {
            titleLabel?.font = titleFont
            setupTransparencyMask()
        }
    }

    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setupTransparencyMask()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        setupTransparencyMask()
    }

    private let normalBackgroundColor = UIColor.primary
    private let disabledBackgroundColor = UIColor.primaryDisabled
    private let highlightedBackgroundColor = UIColor.primaryHighlighted

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension PrimaryButton {
    func setup() {
        setupBackgroundColor()
        clipsToBounds = true
        setTitleColor(.clear, for: .normal)
        titleLabel?.backgroundColor = .clear
        titleLabel?.font = titleFont
    }

    func setupBackgroundColor() {
        backgroundColor = isEnabled ? (isHighlighted ? highlightedBackgroundColor :
            normalBackgroundColor) : disabledBackgroundColor
    }

    func setupTransparencyMask() {
        guard let text = titleLabel?.text, let font = titleLabel?.font else {
            return
        }

        let buttonSize = bounds.size
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = text.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)

            let center = CGPoint(x: buttonSize.width / 2 - textSize.width / 2,
                                 y: buttonSize.height / 2 - textSize.height / 2)
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
            context.addPath(path.cgPath)
            context.fillPath()
            context.setBlendMode(.destinationOut)

            titleLabel?.text?.draw(at: center, withAttributes: attributes)

            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()

                let maskLayer = CALayer()
                maskLayer.contents = image.cgImage as AnyObject
                maskLayer.frame = bounds

                layer.mask = maskLayer
            }
        }
    }
}
