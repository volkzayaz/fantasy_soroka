//
//  UIImage+TabbarUtils.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 04.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension UIImage {

    func resize(for imageSize: Int) -> UIImage {

        let rect = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)

        return UIGraphicsImageRenderer(size: rect.size).image { ctx in
            UIBezierPath.init(roundedRect: rect, cornerRadius: CGFloat(imageSize/2)).addClip()
            draw(in: rect, blendMode: .normal, alpha: 1.0)
        }.withRenderingMode(.alwaysOriginal)
    }

    func addPinkCircle(for imageSize: Int) -> UIImage {

        let maxRect = CGRect(x: 0, y: 0, width: imageSize + 8, height: imageSize + 8)
        let mediumRect = CGRect(x: 2, y: 2, width: imageSize + 4, height: imageSize + 4)
        let imageRect = CGRect(x: 4, y: 4, width: imageSize, height: imageSize)

        let renderer = UIGraphicsImageRenderer(size: maxRect.size)

        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.fantasyPink.cgColor)
            ctx.cgContext.fillEllipse(in: maxRect)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: mediumRect)

            UIBezierPath.init(roundedRect: imageRect, cornerRadius: CGFloat(imageSize/2)).addClip()
            draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        }.withRenderingMode(.alwaysOriginal)
    }

}
