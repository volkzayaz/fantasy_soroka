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
        animateContentOffsetChange(contentOffset: .zero)
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
            self.backgroundImageCenterY.constant = 0
            self.unzoomedBackgroundConstratint.isActive = false
            self.zoomedBackgroundConstratint.isActive = true
            self.titleLabel.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.optionButton.alpha = 0.0
            self.view.layoutIfNeeded()
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
            self.zoomedBackgroundConstratint.isActive = false
            self.unzoomedBackgroundConstratint.isActive = true
            self.titleLabel.alpha = 1.0
            self.closeButton.alpha = 1.0
            self.optionButton.alpha = 1.0
        }) { [weak self] _ in
            guard let self = self else { return }
            self.stackView.isHidden = false
            let expectedOffsetY = UIScreen.main.bounds.height * FantasyDetailsViewController.initialScrollViewRatio
            let offsetY = self.scrollView.contentSize.height >= self.scrollView.frame.size.height + expectedOffsetY ?
                expectedOffsetY : self.scrollView.contentSize.height - self.scrollView.frame.size.height
            self.animateContentOffsetChange(contentOffset: CGPoint(x: 0, y: offsetY))
        }
    }

    private func animateContentOffsetChange(contentOffset: CGPoint) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseIn,
                       animations: {
            self.scrollView.setContentOffset(contentOffset, animated: false)
        })
    }

    func animateZoom() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
            self.unzoomedBackgroundConstratint.isActive = false
            self.zoomedBackgroundConstratint.isActive = true
            self.backgroundImageCenterY.constant = 0
            self.backgroundImageLeftMargin.constant = Fantasy.LayoutConstants.minBackgroundImageMargin
            self.backgroundImageRightMargin.constant = Fantasy.LayoutConstants.minBackgroundImageMargin
            self.view.layoutIfNeeded()
        })

        scrollView.setContentOffset(.zero, animated: true)
    }

    func animateUnzoom() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
            self.zoomedBackgroundConstratint.isActive = false
            self.unzoomedBackgroundConstratint.isActive = true
            self.backgroundImageCenterY.constant = 0
            self.backgroundImageLeftMargin.constant = Fantasy.LayoutConstants.backgroundImageMargin
            self.backgroundImageRightMargin.constant = Fantasy.LayoutConstants.backgroundImageMargin
            self.view.layoutIfNeeded()
        })

        let expectedOffsetY = UIScreen.main.bounds.height * FantasyDetailsViewController.initialScrollViewRatio
        let offsetY = scrollView.contentSize.height >= scrollView.frame.size.height + expectedOffsetY ?
            expectedOffsetY : scrollView.contentSize.height - scrollView.frame.size.height

        animateContentOffsetChange(contentOffset: CGPoint(x: 0, y: offsetY))
    }
}
