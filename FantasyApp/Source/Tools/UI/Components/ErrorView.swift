//
//  ErrorView.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 29.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

public class ErrorView: UIView {
    private let imageView = UIImageView()
    private let label = UILabel()

    public var image: UIImage? = R.image.textFieldError() {
        didSet {
            imageView.image = image
        }
    }

    public var text: String? {
        didSet {
            label.text = text
        }
    }

    public var textColor: UIColor = .title {
        didSet {
            label.textColor = textColor
        }
    }

    public var font: UIFont = .regularFont(ofSize: 15) {
        didSet {
            label.font = font
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

private extension ErrorView {
    func configure() {
        [imageView, label].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        backgroundColor = .errorViewBackground
        configureLayout()

        label.textColor = textColor
        label.font = font
        label.text = text

        imageView.image = image
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),

            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
}
