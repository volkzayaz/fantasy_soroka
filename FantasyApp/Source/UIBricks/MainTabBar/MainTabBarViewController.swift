//
//  MainTabBarViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

extension UIImage {

    func addPinkCircle() -> UIImage {

        let rect = CGRect(x: -1, y: -1, width: size.width + 2, height: size.height + 2)
        let renderer = UIGraphicsImageRenderer(size: rect.size)

        return renderer.image { ctx in

            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.fillEllipse(in: rect)

            draw(in: rect, blendMode: .normal, alpha: 1.0)

        }.withRenderingMode(.alwaysOriginal)
    }
}

class MainTabBarViewController: UITabBarController, MVVM_View {
    
    var viewModel: MainTabBarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.locationRequestHidden
            .drive(onNext: { [unowned self] (hidden) in
                
                if hidden {
                    if self.presentedViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    let vc = R.storyboard.user.searchLocationRestrictedViewController()!
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.profileTabImage
            .drive(onNext: { [unowned self] (image) in
                let i = image.addPinkCircle()
                self.tabBar.items!.last!.selectedImage = i
                self.tabBar.items!.last!.image = image
            })
            .disposed(by: rx.disposeBag)

        viewModel.unsupportedVersionTrigger
            .drive(onNext: { [unowned self] _ in
                
                let vc = R.storyboard.user.updateAppViewController()!
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        let vc = (viewControllers![1] as! UINavigationController).viewControllers.first! as! DiscoverProfileViewController
        vc.viewModel = DiscoverProfileViewModel(router: .init(owner: vc))

        //selectedIndex = 3
        
    }
    
}

private extension MainTabBarViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }

     */
    
}
