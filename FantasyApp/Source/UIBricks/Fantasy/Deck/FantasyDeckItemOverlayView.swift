//
//  FantasyDeckItemOverlayView.swift
//  FantasyApp
//
//  Created by Admin on 28.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Koloda

class FantasyDeckItemOverlayView: OverlayView {
    private let backgroundView = UIView(frame: .zero)
    private let imageView = UIImageView(frame: .zero)
    private let label = UILabel(frame: .zero)

    override func update(progress: CGFloat) {
        super.update(progress: progress)

        guard let state = overlayState else {
            return
        }
        label.text = state == .right ? R.string.localizable.fantasyCardLikeSwipeAction() :
            R.string.localizable.fantasyCardDislikeSwipeAction()
        imageView.image = state == .right ? R.image.deckLike() : R.image.deckDislike()
        backgroundView.backgroundColor = state == .right ? .fantasyPink : .black
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureStyling()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
        configureStyling()
    }
}

private extension FantasyDeckItemOverlayView {
    func configureLayout() {
        addSubview(backgroundView)
        addSubview(imageView)
        addSubview(label)

        [imageView, label, backgroundView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.heightAnchor.constraint(equalToConstant: 108),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
    }

    func configureStyling() {
        label.textColor = .title
        label.font = .boldFont(ofSize: 25)

        layer.cornerRadius = 14.0
        clipsToBounds = true
    }
}
