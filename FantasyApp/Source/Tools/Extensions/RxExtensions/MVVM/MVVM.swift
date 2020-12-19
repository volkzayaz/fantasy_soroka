//
//  MVVM.swift
//   
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016  . All rights reserved.
//

import UIKit

////generic ViewController that requires all controllers to have ViewModels
protocol MVVM_View {
    
    associatedtype VM: MVVM_ViewModel
    
    ///until apple allows creating custom intializers for ViewControllers created from storyboards, we are using unwrapped optionals to shut up the compiler
    var viewModel: VM! { get }
}

protocol MVVM_ViewModel {
    
    associatedtype T: MVVM_Router
    
    var router: T { get }
    
}

protocol MVVM_Router {
    
    associatedtype T

    // In protocol implementation router should always have just a weak reference to its owner to avoid retain cycles.
    var owner: T { get }
    
    var animatable: ProgressAnimatable { get }
    var messagePresentable: MessagePresentable { get }
}

extension MVVM_Router where T : UIViewController {
    
    var animatable: ProgressAnimatable {
        return owner
    }
    
    var messagePresentable: MessagePresentable {
        return owner
    }
    
}

extension MVVM_Router {
    
    func unwrap(maybeUser: UserProfile?, for owner: UIViewController) -> UserProfile? {
        
        if let x = maybeUser {
            return x
        }
        
        owner.presentMessage(message: .init(title: R.string.localizable.userUnavailableTitle(),
                                            description: R.string.localizable.userUnavailableMessage()))
        
        return nil
    }
    
}

