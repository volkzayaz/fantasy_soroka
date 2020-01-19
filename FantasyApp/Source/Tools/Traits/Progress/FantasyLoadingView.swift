//
//  FantasyLoadingView.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class FantasyLoadingView: UIView {
    
    var active: Bool = false
    private var animationTimer: Timer?
    private var scale: CGFloat!
    
    private var logoPath: UIBezierPath? {
        
        let shapePath = UIBezierPath()
        shapePath.move(to: CGPoint(x: 153.52, y: 35.87))
        
        shapePath.addCurve(to: CGPoint(x: 142.6, y: 28.54), controlPoint1:CGPoint(x: 150.41, y: 32.77), controlPoint2:CGPoint(x: 146.71, y: 30.27))
        shapePath.addCurve(to: CGPoint(x: 133.08, y: 9.96),controlPoint1: CGPoint(x: 141.43, y: 21.35), controlPoint2:CGPoint(x: 138.02, y: 14.89))
        shapePath.addCurve(to: CGPoint(x: 109, y: 0), controlPoint1:CGPoint(x: 126.92, y: 3.81), controlPoint2:CGPoint(x: 118.4, y: 0))
        shapePath.addCurve(to:CGPoint(x: 109, y: 0), controlPoint1:CGPoint(x: 126.92, y: 3.81) ,controlPoint2: CGPoint(x: 118.4, y: 0))
        shapePath.addCurve(to:CGPoint(x: 81.75, y: 13.26) ,controlPoint1: CGPoint(x: 98.23, y: 0) ,controlPoint2: CGPoint(x: 88.19, y: 5.38))
        shapePath.addCurve(to:CGPoint(x: 54.5, y: 0) ,controlPoint1: CGPoint(x: 75.15, y: 5.38) ,controlPoint2: CGPoint(x: 65.25, y: 0))
        shapePath.addCurve(to:CGPoint(x: 30.41, y: 9.96) ,controlPoint1: CGPoint(x: 45.09, y: 0) ,controlPoint2: CGPoint(x: 36.58, y: 3.81))
        shapePath.addCurve(to:CGPoint(x: 20.9, y: 28.55) ,controlPoint1: CGPoint(x: 25.47, y: 14.9) ,controlPoint2: CGPoint(x: 22.07, y: 21.35))
        shapePath.addCurve(to:CGPoint(x: 9.98, y: 35.87) ,controlPoint1: CGPoint(x: 16.79, y: 30.27) ,controlPoint2: CGPoint(x: 13.08, y: 32.77))
        shapePath.addCurve(to:CGPoint(x: 0, y: 59.92) ,controlPoint1: CGPoint(x: 3.81, y: 42.02) ,controlPoint2: CGPoint(x: 0, y: 50.53))
        shapePath.addCurve(to:CGPoint(x: 9.98, y: 83.96) ,controlPoint1: CGPoint(x: 0, y: 69.3) ,controlPoint2: CGPoint(x: 3.81, y: 77.8))
        shapePath.addCurve(to:CGPoint(x: 34.06, y: 93.92) ,controlPoint1: CGPoint(x: 16.14, y: 90.11) ,controlPoint2: CGPoint(x: 24.66, y: 93.92))
        shapePath.addCurve(to:CGPoint(x: 58.41, y: 85.64) ,controlPoint1: CGPoint(x: 41.16, y: 93.92) ,controlPoint2: CGPoint(x: 49.8,y:  90.56))
        shapePath.addCurve(to:CGPoint(x: 78.45, y: 71.75) ,controlPoint1: CGPoint(x: 65.29, y: 81.72) ,controlPoint2: CGPoint(x: 72.3,y:  76.73))
        shapePath.addCurve(to:CGPoint(x: 74.12, y: 67.91) ,controlPoint1: CGPoint(x: 76.99, y: 70.48) ,controlPoint2: CGPoint(x: 75.55, y: 69.19))
        shapePath.addCurve(to:CGPoint(x: 68.1, y: 62.64) ,controlPoint1: CGPoint(x: 72.11, y: 66.1) ,controlPoint2: CGPoint(x: 70.11, y: 64.32))
        shapePath.addCurve(to:CGPoint(x: 53.12, y: 72.97) ,controlPoint1: CGPoint(x: 63.4, y: 66.33) ,controlPoint2: CGPoint(x: 58.24,y:  69.93))
        shapePath.addCurve(to:CGPoint(x: 34.55, y: 38.05) ,controlPoint1: CGPoint(x: 43.44, y: 61.09) ,controlPoint2: CGPoint(x: 36.37,y:  49.39))
        shapePath.addCurve(to:CGPoint(x: 35.38, y: 26.85) ,controlPoint1: CGPoint(x: 33.93, y: 34.19) ,controlPoint2: CGPoint(x: 33.99, y: 30.54))
        shapePath.addCurve(to:CGPoint(x: 40.05, y: 19.58) ,controlPoint1: CGPoint(x: 36.41, y: 24.1) ,controlPoint2: CGPoint(x: 38, y: 21.62))
        shapePath.addCurve(to:CGPoint(x: 54.5, y: 13.6) ,controlPoint1: CGPoint(x: 43.89, y: 15.74) ,controlPoint2: CGPoint(x: 49.06, y: 13.6))
        shapePath.addCurve(to:CGPoint(x: 81.75, y: 32.78) ,controlPoint1: CGPoint(x: 67.63, y: 13.6) ,controlPoint2: CGPoint(x: 75.31, y: 24.99))
        shapePath.addCurve(to:CGPoint(x: 109, y: 13.6) ,controlPoint1: CGPoint(x: 87.51, y: 24.99) ,controlPoint2: CGPoint(x: 95.86, y: 13.6))
        shapePath.addCurve(to:CGPoint(x: 123.45, y: 19.58) ,controlPoint1: CGPoint(x: 114.64, y: 13.6) ,controlPoint2: CGPoint(x: 119.75, y: 15.89))
        shapePath.addCurve(to:CGPoint(x: 127.79, y: 26) ,controlPoint1: CGPoint(x: 125.28, y: 21.41) ,controlPoint2: CGPoint(x: 126.76, y: 23.59))
        shapePath.addCurve(to:CGPoint(x: 105.08, y: 34.19) ,controlPoint1: CGPoint(x: 121.02, y: 26.46) ,controlPoint2: CGPoint(x: 113.05, y: 29.64))
        shapePath.addCurve(to:CGPoint(x: 81.75, y: 50.83) ,controlPoint1: CGPoint(x: 96.79, y: 38.92) ,controlPoint2: CGPoint(x: 89, y: 44.63))
        shapePath.addCurve(to:CGPoint(x: 58.41, y: 34.19) ,controlPoint1: CGPoint(x: 74.89, y: 44.97) ,controlPoint2: CGPoint(x: 66.56, y: 38.83))
        
        shapePath.addLine(to: CGPoint(x: 57.75, y: 33.81))
        
        shapePath.addCurve(to:CGPoint(x: 40.1, y: 26.61), controlPoint1:CGPoint(x: 51.68, y: 30.4), controlPoint2:CGPoint(x: 45.61, y: 27.8))
        shapePath.addCurve(to:CGPoint(x: 39.64, y: 27.56), controlPoint1:CGPoint(x: 39.94, y: 26.92), controlPoint2:CGPoint(x: 39.79, y: 27.24))
        shapePath.addCurve(to:CGPoint(x: 38.32, y: 33.28), controlPoint1:CGPoint(x: 38.87, y: 29.33), controlPoint2:CGPoint(x: 38.41, y: 31.26))
        
        shapePath.addLine(to: CGPoint(x: 38.34, y: 33.68))
        shapePath.addLine(to: CGPoint(x: 38.35, y: 33.78))
        shapePath.addLine(to: CGPoint(x: 38.35, y: 33.8))
        
        shapePath.addCurve(to:CGPoint(x: 39.33, y: 40.39), controlPoint1:CGPoint(x: 38.44, y: 35.97), controlPoint2:CGPoint(x: 38.78, y: 38.17))
        shapePath.addCurve(to:CGPoint(x: 51.65, y: 45.98), controlPoint1:CGPoint(x: 43, y: 41.47), controlPoint2:CGPoint(x: 47.25, y: 43.47))
        shapePath.addCurve(to:CGPoint(x: 60.16, y: 51.35), controlPoint1:CGPoint(x: 54.56,y: 47.64), controlPoint2:CGPoint(x: 57.39, y: 49.45))
        
        shapePath.addLine(to: CGPoint(x: 63.85, y: 53.97))
        
        shapePath.addCurve(to:CGPoint(x: 71.45, y: 59.92), controlPoint1:CGPoint(x: 66.45, y: 55.87), controlPoint2:CGPoint(x: 69, y: 57.85))
        shapePath.addCurve(to:CGPoint(x: 83.1, y: 70.14), controlPoint1:CGPoint(x: 75.26, y: 63.14), controlPoint2:CGPoint(x: 79.13, y: 66.81))
        shapePath.addCurve(to:CGPoint(x: 92.56, y: 77.51), controlPoint1:CGPoint(x: 86.16, y: 72.71), controlPoint2:CGPoint(x: 89.32, y: 75.17))
        shapePath.addCurve(to:CGPoint(x: 101.32, y: 83.39), controlPoint1:CGPoint(x: 95.42, y: 79.58), controlPoint2:CGPoint(x: 98.37, y: 81.56))
        shapePath.addCurve(to:CGPoint(x: 81.75, y: 103.49), controlPoint1:CGPoint(x: 95.21, y: 90.06), controlPoint2:CGPoint(x: 88.54, y: 96.77))
        shapePath.addCurve(to:CGPoint(x: 65.12, y: 86.57), controlPoint1:CGPoint(x: 76.04, y: 97.84), controlPoint2:CGPoint(x: 70.4, y: 92.19))
        shapePath.addCurve(to:CGPoint(x: 60.52, y: 89.33), controlPoint1:CGPoint(x: 63.58, y: 87.54), controlPoint2:CGPoint(x: 62.05, y: 88.46))
        shapePath.addCurve(to:CGPoint(x: 52.83, y: 93.29), controlPoint1:CGPoint(x: 57.96, y: 90.79), controlPoint2:CGPoint(x: 55.38, y: 92.13))
        shapePath.addCurve(to:CGPoint(x: 76.99, y: 117.86), controlPoint1:CGPoint(x: 60.4, y: 101.51), controlPoint2:CGPoint(x: 68.69, y: 109.68))
        
        shapePath.addLine(to: CGPoint(x: 81.79, y: 122.6))
        shapePath.addLine(to: CGPoint(x: 86.56, y: 117.83))
        shapePath.addLine(to: CGPoint(x: 86.57, y: 117.83))
        shapePath.addLine(to: CGPoint(x: 86.55, y: 117.81))
        
        shapePath.addCurve(to:CGPoint(x: 113.68, y: 89.98), controlPoint1:CGPoint(x: 95.94, y: 108.56), controlPoint2:CGPoint(x: 105.33, y: 99.31))
        
        shapePath.addLine(to: CGPoint(x: 113.68, y: 89.98))
        shapePath.addLine(to: CGPoint(x: 113.75, y: 89.9))
        
        shapePath.addCurve(to:CGPoint(x: 118.58, y: 84.35), controlPoint1:CGPoint(x: 115.39, y: 88.07), controlPoint2:CGPoint(x: 117, y: 86.22))
        shapePath.addCurve(to:CGPoint(x: 122.92, y: 79.04), controlPoint1:CGPoint(x: 118.94, y: 83.92), controlPoint2:CGPoint(x: 122.76, y: 78.96))
        shapePath.addCurve(to:CGPoint(x: 140.52, y: 48.15), controlPoint1:CGPoint(x: 130.91, y: 68.88), controlPoint2:CGPoint(x: 137.22, y: 58.61))
        shapePath.addCurve(to:CGPoint(x: 135.64, y: 44.98), controlPoint1:CGPoint(x: 139.09, y: 46.8), controlPoint2:CGPoint(x: 137.44, y: 45.72))
        shapePath.addCurve(to:CGPoint(x: 129.57, y: 43.76), controlPoint1:CGPoint(x: 133.79, y: 44.21), controlPoint2:CGPoint(x: 131.74, y: 43.78))
        
        shapePath.addLine(to: CGPoint(x: 129.44, y: 43.76))
        
        shapePath.addCurve(to:CGPoint(x: 127.57, y: 43.94), controlPoint1:CGPoint(x: 128.87, y: 43.76), controlPoint2:CGPoint(x: 128.24, y: 43.82))
        shapePath.addCurve(to:CGPoint(x: 110.37, y: 72.98), controlPoint1:CGPoint(x: 124.63, y: 53.43), controlPoint2:CGPoint(x: 118.39, y: 63.14))
        shapePath.addCurve(to:CGPoint(x: 92.67, y: 60.44), controlPoint1:CGPoint(x: 104.24, y: 69.35), controlPoint2:CGPoint(x: 98.05, y: 64.87))
        
        shapePath.addLine(to: CGPoint(x: 92.6, y: 60.38))
        shapePath.addLine(to: CGPoint(x: 92.04, y: 59.92))
        shapePath.addLine(to: CGPoint(x: 92.6, y: 59.45))
        shapePath.addLine(to: CGPoint(x: 92.67, y: 59.39))
        
        shapePath.addCurve(to:CGPoint(x: 111.84, y: 45.98), controlPoint1:CGPoint(x: 98.48, y: 54.6), controlPoint2:CGPoint(x: 105.23, y: 49.75))
        shapePath.addCurve(to:CGPoint(x: 129.44, y: 39.51), controlPoint1:CGPoint(x: 118.58, y: 42.14), controlPoint2:CGPoint(x: 124.93, y: 39.51))
        shapePath.addCurve(to:CGPoint(x: 143.89, y: 45.49), controlPoint1:CGPoint(x: 135.08, y: 39.51), controlPoint2:CGPoint(x: 140.19, y: 41.8))
        shapePath.addCurve(to:CGPoint(x: 149.87, y: 59.92), controlPoint1:CGPoint(x: 147.59, y: 49.18), controlPoint2:CGPoint(x: 149.87, y: 54.28))
        shapePath.addCurve(to:CGPoint(x: 143.89, y: 74.34), controlPoint1:CGPoint(x: 149.87, y: 65.55), controlPoint2:CGPoint(x: 147.59, y: 70.65))
        shapePath.addCurve(to:CGPoint(x: 129.44, y: 80.32), controlPoint1:CGPoint(x: 140.19, y: 78.03), controlPoint2:CGPoint(x: 135.08, y: 80.32))
        shapePath.addCurve(to:CGPoint(x: 127.43, y: 80.17), controlPoint1:CGPoint(x: 128.8, y: 80.32), controlPoint2:CGPoint(x: 128.13, y: 80.27))
        shapePath.addCurve(to:CGPoint(x: 117.89, y: 91.64), controlPoint1:CGPoint(x: 124.47, y: 84.01), controlPoint2:CGPoint(x: 121.26, y: 87.84))
        shapePath.addCurve(to:CGPoint(x: 129.44, y: 93.92), controlPoint1:CGPoint(x: 121.99, y: 93.09), controlPoint2:CGPoint(x: 125.91, y: 93.92))
        shapePath.addCurve(to:CGPoint(x: 153.52, y: 83.96), controlPoint1:CGPoint(x: 138.84, y: 93.92), controlPoint2:CGPoint(x: 147.36, y: 90.11))
        shapePath.addCurve(to:CGPoint(x: 163.5, y: 59.92), controlPoint1:CGPoint(x: 159.69, y: 77.81), controlPoint2:CGPoint(x: 163.5, y: 69.3))
        shapePath.addCurve(to:CGPoint(x: 153.52, y: 35.87), controlPoint1:CGPoint(x: 163.5, y: 50.53), controlPoint2:CGPoint(x: 159.68, y: 42.02))
        
        shapePath.addLine(to: CGPoint(x: 153.52, y: 35.87))
        shapePath.close()
        
        shapePath.move(to: CGPoint(x: 19.61, y: 74.34))
        
        shapePath.addCurve(to:CGPoint(x: 13.62, y: 59.92), controlPoint1:CGPoint(x: 15.91, y: 70.65), controlPoint2:CGPoint(x: 13.62, y: 65.55))
        shapePath.addCurve(to:CGPoint(x: 19.61, y: 45.49), controlPoint1:CGPoint(x: 13.62, y: 54.28), controlPoint2:CGPoint(x: 15.91, y: 49.18))
        shapePath.addCurve(to:CGPoint(x: 21.76, y: 43.65), controlPoint1:CGPoint(x: 20.28, y: 44.82), controlPoint2:CGPoint(x: 21, y: 44.22))
        shapePath.addCurve(to:CGPoint(x: 40.57, y: 79.03), controlPoint1:CGPoint(x: 24.52, y: 55.67), controlPoint2:CGPoint(x: 31.44, y: 67.42))
        shapePath.addCurve(to:CGPoint(x: 34.06, y: 80.32), controlPoint1:CGPoint(x: 38.16, y: 79.84), controlPoint2:CGPoint(x: 35.94, y: 80.32))
        shapePath.addCurve(to:CGPoint(x: 19.61, y: 74.34), controlPoint1:CGPoint(x: 28.42, y: 80.32), controlPoint2:CGPoint(x: 23.31, y: 78.03))
        shapePath.addLine(to: CGPoint(x: 19.61, y: 74.34))
        
        shapePath.close()
        shapePath.usesEvenOddFillRule = true
        UIColor(red: 0.435, green: 0.933, blue: 0.835, alpha: 1.0).setFill()
        shapePath.fill()
        shapePath.apply(CGAffineTransform(scaleX: self.scale, y: self.scale))
        
        return shapePath
    }
    
    let gradientImage: UIImageView = UIImageView.init(image: R.image.loader_gradient()!)
    let gradientLayerWidth = 400.0
    let gradientLayerHeight = 200.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        baseInit()
    }
    
    private func baseInit() {
        scale = frame.size.width/164;
        
        gradientImage.frame = CGRect(x: -200, y: -2, width: frame.size.width, height: frame.size.height)
        
        addSubview(gradientImage)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = logoPath?.cgPath
        layer.mask = maskLayer
    }
    
    public func startAnimation() {
        animationTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(animateLogo), userInfo: nil, repeats: true)
        animationTimer?.fire()
        active = true
    }
    
    public func stopAnimation() {
        active = false
        animationTimer?.invalidate()
    }
    
    @objc private func animateLogo() {
        UIView.animate(withDuration: 1.95, animations: {
            self.gradientImage.frame = CGRect(x: -1, y: -2, width: self.gradientLayerWidth, height: self.gradientLayerHeight)
        }) { _ in
            self.gradientImage.frame = CGRect(x: -200, y: -2, width: self.gradientLayerWidth, height: self.gradientLayerHeight)
        }
        
    }
}

//MARK:- FantasyLoadingViewSingle

class AnimatedFantasyLogoView: FantasyLoadingView {
    
    public override func startAnimation() {
        // ignore start if animation is inprogress
        guard active == false else {
            return
        }
        
        gradientImage.frame = CGRect(x: -gradientLayerWidth, y: -2, width: gradientLayerWidth, height: gradientLayerHeight)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.gradientImage.frame = CGRect(x: 0, y: 0, width: self.gradientLayerWidth, height: self.gradientLayerHeight)
        }) { _ in
            UIView.animate(withDuration: 2.0, animations: {
                self.gradientImage.frame = CGRect(x: -self.gradientLayerWidth, y: 0, width: self.gradientLayerWidth, height: self.gradientLayerHeight)
            }) {_ in
                self.active = false
            }
        }
        
    }
    
}
