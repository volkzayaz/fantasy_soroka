//
//  FantasyDetailsViewController+Animations.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 25.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension FantasyDetailsViewController {
    func animatePreferenceChange(_ reaction: Fantasy.Card.Reaction) {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            self.equalButtonsWidth.isActive = reaction == .neutral
            self.likeSelectedWidth.isActive = reaction != .like
            self.dislikeSelectedWidth.isActive = reaction != .dislike
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.dislikeLabel.isHidden = reaction != .dislike
            self?.dislikesCountLabel.isHidden = reaction != .dislike
            self?.likeLabel.isHidden = reaction != .like
            self?.likesCountLabel.isHidden = reaction != .like
        }
    }

    func animateDisappearance() {
        gradientBackgroundView.isHidden = true
        backgroundView.isHidden = true
        scrollView.setContentOffset(.zero, animated: true)
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
            self.titleLabel.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.optionButton.alpha = 0.0
        }) { [weak self] _ in
            self?.viewModel.close()
        }
    }

    func animateAppearance() {
        backgroundView.isHidden = false
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
            self.titleLabel.alpha = 1.0
            self.closeButton.alpha = 1.0
            self.optionButton.alpha = 1.0
        }) { [weak self] _ in
            guard let self = self else { return }
            self.animateContentOffsetChange(contentOffset: CGPoint(x: 0, y: FantasyDetailsViewController.initialScrollViewOffsetY))
        }
    }

    func animateCardScale(toSize size: CGSize) {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2.0,
                       options: .curveEaseIn,
                       animations: {
            let width = max(size.width, FantasyDetailsViewController.minBackgroundImageWidth)
            let height = max(size.height, FantasyDetailsViewController.minBackgroundImageHeight)
            self.backgroundImageWidth.constant = width
            self.backgroundImageHeight.constant = min(height, UIScreen.main.bounds.height)
            self.backgroundImageView.layoutIfNeeded()
        })
    }

    func animateContentOffsetChange(contentOffset: CGPoint) {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseIn,
                       animations: {
            self.scrollView.setContentOffset(contentOffset, animated: false)
        })
    }
}
