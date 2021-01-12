//
//  FantasyHorizontalGradientView.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 26.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

class FantasyHorizontalGradientView: UIView {
    
    @IBInspectable var onlyBorder: Bool = false {
        didSet {
            updateMask()
        }
    }
    
    override open class var layerClass: Swift.AnyClass {
        get {
            return FantasyHorizontalGradientLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}

private extension FantasyHorizontalGradientView {
    
    func setUp() {
        rx.observe(CGRect.self, #keyPath(UIView.bounds))
            .subscribe(onNext: { [unowned self] _ in
                self.updateMask()
            }).disposed(by: rx.disposeBag)
        
        rx.observe(CGRect.self, #keyPath(UIView.layer.cornerRadius))
            .subscribe(onNext: { [unowned self] _ in
                self.updateMask()
            }).disposed(by: rx.disposeBag)
    }
    
    func updateMask() {
        if onlyBorder {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            mask.fillColor = UIColor.clear.cgColor
            mask.strokeColor = UIColor.white.cgColor
            mask.lineWidth = 2

            layer.mask = mask
        } else {
            layer.mask = nil
        }
    }
}
