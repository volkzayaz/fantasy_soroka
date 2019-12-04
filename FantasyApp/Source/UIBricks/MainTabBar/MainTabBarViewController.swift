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
 
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        guard motion == .motionShake && (Environment.debug || Environment.adhoc) else {
            return
        }
        
        let actions: [UIAlertAction] = [UIAlertAction(title: "Force Update Application",
                                                      style: .default,
                                                      handler: { [weak self] _ in
                                                        self?.viewModel.triggerUpdate()
        }),
        .init(title: "Cancel", style: .cancel, handler: nil)]
        
        showDialog(title: "Debug Actions", text: "Pick one", style: .alert,
                   actions: actions)
        
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
