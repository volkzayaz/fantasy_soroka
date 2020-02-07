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
    public enum Mode {
        case normal
        case selector
    }
    
    var useTransparency = true {
        didSet {
            setupTransparencyMask()
        }
    }

    public var mode: Mode = .normal {
        didSet {
            setupBackgroundColor()
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            setupBackgroundColor()
        }
    }

    public override var isSelected: Bool {
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

    var normalBackgroundColor = UIColor.primary
    var disabledBackgroundColor = UIColor.primaryDisabled
    private let highlightedBackgroundColor = UIColor.primaryHighlighted

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setBugFixMode() {
        setTitleColor(UIColor.fantasyPink, for: .highlighted)
        setTitleColor(UIColor.fantasyPink, for: .selected)
        setTitleColor(.white, for: .normal)
    }
}

extension PrimaryButton {
    func setup() {
        setupBackgroundColor()
        clipsToBounds = true
        
        setTitleColor(.clear, for: .normal)
        titleLabel?.backgroundColor = .clear
        titleLabel?.font = titleFont
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    }

    func setupBackgroundColor() {
        switch mode {
        case .normal:
            backgroundColor = isEnabled ? (isHighlighted ? highlightedBackgroundColor :
                normalBackgroundColor) : disabledBackgroundColor
            
        case .selector:
            backgroundColor = isSelected ? (isHighlighted ? highlightedBackgroundColor :
                normalBackgroundColor) : disabledBackgroundColor

        }
    }

    func setupTransparencyMask() {
        guard let text = titleLabel?.text, let font = titleLabel?.font, useTransparency else {
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
