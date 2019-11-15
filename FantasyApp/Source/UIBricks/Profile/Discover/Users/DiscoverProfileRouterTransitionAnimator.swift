//
//  DiscoverProfileRouterTransitionAnimator.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 23.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class DiscoverProfileRouterTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    static let durationExpanding = 0.4
    static let durationClosing = 0.5
    
    var originFrame = CGRect.zero
    var presenting = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? DiscoverProfileRouterTransitionAnimator.durationExpanding :
            DiscoverProfileRouterTransitionAnimator.durationClosing
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ratio = originFrame.width / (UIScreen.main.bounds.width -
            2.0 * Fantasy.LayoutConstants.backgroundImageMargin)
        let width = originFrame.width + (2.0 * Fantasy.LayoutConstants.backgroundImageMargin * ratio)
        let height = UIScreen.main.bounds.height * ratio
        let originX = originFrame.origin.x - Fantasy.LayoutConstants.backgroundImageMargin * ratio
        let originY = originFrame.origin.y - (height - originFrame.height) / 2.0
        let sourceFrame = CGRect(x: originX, y: originY, width: width, height: height)

        let containerView = transitionContext.containerView

        guard let detailView = presenting ? transitionContext.view(forKey: .to)
            : transitionContext.view(forKey: .from) else {
            return
        }

        let initialFrame = presenting ? sourceFrame : detailView.frame
        let finalFrame = presenting ? detailView.frame : sourceFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        if presenting {
            detailView.transform = scaleTransform
            detailView.center = CGPoint( x: initialFrame.midX, y: initialFrame.midY)
            detailView.clipsToBounds = true
        }

        containerView.backgroundColor = presenting ? .clear : .fantasyCardBackground
        containerView.addSubview(detailView)
        containerView.bringSubviewToFront(detailView)

        // background color animation
        UIView.animate(
            withDuration: presenting ? DiscoverProfileRouterTransitionAnimator.durationExpanding :
                DiscoverProfileRouterTransitionAnimator.durationClosing,
            delay: 0.0,
            options: presenting ? .curveEaseIn : .curveEaseOut,
            animations: {
                containerView.backgroundColor = self.presenting ? .fantasyCardBackground : .clear
            }
        )

        // view transition
        UIView.animate(
            withDuration: presenting ? DiscoverProfileRouterTransitionAnimator.durationExpanding :
                DiscoverProfileRouterTransitionAnimator.durationClosing,
            delay: 0.0,
            usingSpringWithDamping: presenting ? 0.5 : 0.5,
            initialSpringVelocity: presenting ? 0.5 : 2.0,
            options: presenting ? .curveEaseIn : .curveEaseOut,
            animations: {
                detailView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                detailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
