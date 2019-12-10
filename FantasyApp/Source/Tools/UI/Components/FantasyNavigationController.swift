//
//  FantasyNavigationController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

//MARK:- FantasyPinkNavigationController

class FantasyPinkNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureNavigationBar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configureNavigationBar() {
        navigationBar.applyFantasyStyling()
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item

        setNavigationBarHidden(viewController.prefersNavigationBarHidden, animated: true)

    }
}

//MARK:- FantasyNavigationController

class FantasyNavigationController: FantasyPinkNavigationController {
    override func configureNavigationBar() {
        navigationBar.applyFantasyTransparentStyling()
    }
}

//MARK:- UIViewController Extension

extension UIViewController {
    
    @objc var prefersNavigationBarHidden: Bool {
        return false
    }
    
}

//MARK:- CAGradientLayer Extension

extension CAGradientLayer {
    var imageFromGradientLayer: UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}

//MARK:- UINavigationBar Extension

extension UINavigationBar {

    private func applyFontStyling() {
        titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        tintColor = .white
    }

    func applyFantasyStyling() {
        applyFontStyling()
        isTranslucent = false

        let gradient = CAGradientLayer()
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds

        let c1 = UIColor(red: 184.0/255.0, green: 141.0/255.0, blue: 218.0/255.0, alpha: 1.0).cgColor
        let c2 = UIColor(red: 237.0/255.0, green: 61.0/255.0, blue: 138.0/255.0, alpha: 1.0).cgColor

        gradient.colors = [c1, c2]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        if let image = gradient.imageFromGradientLayer {
            setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }

    func applyFantasyTransparentStyling() {
        applyFontStyling()
        isTranslucent = true
        backgroundColor = .clear
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
    }
}
