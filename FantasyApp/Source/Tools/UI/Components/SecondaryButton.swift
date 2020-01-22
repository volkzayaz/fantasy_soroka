//
//  SecondaryButton.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

public class SecondaryButton: UIButton {
    public override var isHighlighted: Bool {
        didSet {
            setupLayers()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            setupLayers()
        }
    }

    public var titleFont: UIFont = .boldFont(ofSize: 16) {
        didSet {
            titleLabel?.font = titleFont
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
    }

    private let highlightedShadowRadius: CGFloat = 31.0
    var normalShadowRadius: CGFloat = 21.0 {
        didSet {
            setupLayers()
        }
    }
    private let gradientColors = [UIColor.gradient2, UIColor.gradient3]
    private var gradientLayer: CAGradientLayer?
    private var shadowLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension SecondaryButton {
    func setup() {
        setTitleColor(.title, for: .normal)
        titleLabel?.backgroundColor = .clear
        titleLabel?.font = titleFont
    }

    func setupLayers() {
        setupShadow()
        setupGradient()
    }

    func setupGradient() {
        if let layer = gradientLayer {
            layer.removeFromSuperlayer()
        }

        let colors: [UIColor] = gradientColors.map(
            isEnabled ? (isHighlighted ? { $0.darker() } : { $0 }) : { $0.withAlphaComponent(0.3) }
        )

        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = bounds
        gradientLayer!.colors = colors.map { $0.cgColor }
        gradientLayer!.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer!.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer!.cornerRadius = bounds.height / 2.0
        shadowLayer!.insertSublayer(gradientLayer!, at: 0)
    }

    func setupShadow() {
        if let layer = shadowLayer {
            layer.removeFromSuperlayer()
        }
        shadowLayer = CAShapeLayer()
        shadowLayer!.fillColor = UIColor.white.cgColor
        shadowLayer!.shadowRadius = isHighlighted ? highlightedShadowRadius : normalShadowRadius
        shadowLayer!.shadowOpacity = 0.5
        shadowLayer!.shadowColor = UIColor.shadow.cgColor
        shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.insertSublayer(shadowLayer!, at: 0)
        setupGradient()
    }
}
