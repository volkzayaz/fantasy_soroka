//
//  RootViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Crashlytics

class RootViewController: FantasyBaseNavigationController, MVVM_View {
    
    lazy var viewModel: RootViewModel! = .init(router: .init(owner: self))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.state
            .drive(onNext: { [unowned self] (x) in
                
                switch x {
                    
                case .mainApp:
                    let vc = R.storyboard.main.mainTabBarViewController()!
                    vc.viewModel = .init(router: .init(owner: vc))
                    self.setViewControllers([vc], animated: true)
                    
                case .authentication:
                    let vc = R.storyboard.authorization.welcomeViewController()!
                    vc.viewModel = .init(router: .init(owner: vc))
                    self.setViewControllers([vc], animated: true)
                    
                case .ageRestriction:
                    let vc = R.storyboard.authorization.ageRestrictionViewConrtoller()!
                    self.setViewControllers([vc], animated: true)
                    
                case .updateApp:
                    let vc = R.storyboard.user.updateAppViewController()!
                    self.present(vc, animated: true, completion: nil)
                
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.blocked
            .filter { $0 }
            .drive(onNext: { [unowned self] (_) in
                
                let vc = R.storyboard.authorization.blockedViewController()!
                self.setViewControllers([vc], animated: true)

            })
            .disposed(by: rx.disposeBag)
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
        
        guard motion == .motionShake && (RunScheme.debug || RunScheme.adhoc) else {
            return
        }
        
        let actions: [UIAlertAction] = [
            
            UIAlertAction(title: "Force Update Application",
                          style: .default,
                          handler: { [weak self] _ in
                            
                            self?.viewModel.triggerUpdate()
                            
            }),
            
            .init(title: "Change environment",
                style: .default,
                handler: { [weak self] _ in
                    self?.envChange()
            }),
            
            .init(title: "Cancel", style: .cancel, handler: nil)]
        
        showDialog(title: "Debug Actions", text: "Pick one", style: .alert,
                   actions: actions)
        
    }
    
    private func envChange() {
        
        var actions: [UIAlertAction] =
            Environment.allCases.map { env in
                
                UIAlertAction(title: env.rawValue,
                              style: .default,
                              handler: { _ in
                                
                                SettingsStore.environment.value = env
                                AuthenticationManager.logout()
                                Dispatcher.dispatch(action: Logout())
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    ///just so we don't pollute crash logs
                                    exit(0) //alledgedly produces this crash
                                    // // https://console.firebase.google.com/u/1/project/fantasymatch-51c21/crashlytics/app/ios:com.fantasyapp.iosclient/issues/5d7d9d93f86080d57df4ce0c085193cb
                                }
                })
                
        }
            
        actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
        
        showDialog(title: "Current environment -- \(SettingsStore.environment.value.serverAlias)",
            text: "You will be logged out. Application will be closed. Launch it manually to use new environment",
            style: .alert,
                   actions: actions)
        
    }
}
