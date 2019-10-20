//
//  SexualityGradientView.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 27.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import MetalKit
import Foundation

// Important: This doesn't work on simulator previous to iOS 13

class SexualityGradientView: MTKView {
    private let renderer = SexualityGradientRenderer()
    private var workItem: DispatchWorkItem?

    public var sexuality: Sexuality? {
        set {
            if fromSexuality == nil {
                fromSexuality = newValue
            }
            toSexuality = newValue
            
            #if !targetEnvironment(simulator)
            animateSexualitySelection(newValue)
            #endif
        }
        get {
            return fromSexuality
        }
    }
    private var fromSexuality: Sexuality?
    private var toSexuality: Sexuality?
    private var isAnimationInProgress = false

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        configure()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    @objc func valueChanged(sender: UISlider) {
        renderer.progress = sender.value / sender.maximumValue
    }

    private func configure() {
        framebufferOnly = false
        delegate = renderer
        device = renderer.device
        let displayLink = CADisplayLink(target: self, selector: #selector(incrementProgress))
        displayLink.add(to: .current, forMode: .common)
    }

    private func animateSexualitySelection(_ sexuality: Sexuality?) {
        guard let fromSexuality = fromSexuality,
            let toSexuality = toSexuality else {
                return
        }
        renderer.fromTextureResource = UIImage(named: fromSexuality.rawValue)?.cgImage
        renderer.toTextureResource = renderer.fromTextureResource
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.renderer.fromTextureResource = UIImage(named: fromSexuality.rawValue)?.cgImage
            self.renderer.toTextureResource = UIImage(named: toSexuality.rawValue)?.cgImage
            self.renderer.progress = 0
            self.isAnimationInProgress = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem!)
    }

    @objc func incrementProgress() {
        guard isAnimationInProgress else {
            return
        }
        if renderer.progress < 1 {
            renderer.progress += 0.01
        } else {
            fromSexuality = toSexuality
            isAnimationInProgress = false
        }
    }
}
