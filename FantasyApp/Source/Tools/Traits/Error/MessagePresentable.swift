//
//  PresentMessage.swift
//     
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016    All rights reserved.
//

import UIKit
import RxSwift

struct DisplayMessage {
    let title: String
    let description: String
}

protocol MessagePresentable {
    
    func present(error: Error)
    func presentMessage(_: String)
    func presentMessage(message: DisplayMessage)
    
}

extension MessagePresentable {
    
    func presentMessage(_ message: String) {
        presentMessage(message: DisplayMessage(title: R.string.localizable.generalError(), description: message))
    }
    
    func present(error: Error) {
        
        if case .canceled? = error as? FantasyError {
            return
        }
        
        if case .generic(let message)? = error as? FantasyError {
            presentMessage(message)
            return
        }
        
        if case .apiError(let x)? = error as? FantasyError {
            presentMessage(x.message)
            return
        }
        
        if case .dataCorrupted? = error as? ParseMigrationError {
            presentMessage( R.string.localizable.authorizationMigrationDataCorrupted() )
            return
        }
        
        presentMessage(error.localizedDescription)
    }
}


extension UIViewController: MessagePresentable {
    
    fileprivate func onLoadedView<T>(observable: Observable<T>) -> Observable<T> {
        
        if self.isViewLoaded {
            return observable.subscribeOn(MainScheduler.instance)
        }
        else {
            return rx.sentMessage(#selector(UIViewController.viewDidLoad))
                .flatMapLatest { _ in observable }
                .subscribeOn(MainScheduler.instance)
        }

    }
    
    func presentMessage(message: DisplayMessage) {
        let _ = onLoadedView(observable: Observable.just(message))
            .subscribe(onNext: { [unowned self] m in
                self.showMessage(title: m.title,
                                 text: m.description)
            })
        
    }
    
}
