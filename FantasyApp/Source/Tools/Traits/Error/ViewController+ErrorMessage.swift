//
//  ViewController+ErrorMessage.swift
//   
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016   All rights reserved.
//

import UIKit

typealias MessageCallback = () -> Void

extension UIViewController {
    
    func showMessage(title: String,
                     text: String,
                     style: UIAlertController.Style = .alert,
                     buttonText: String = R.string.localizable.ok(),
                     callback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: style)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: .default) { _ in
            callback?()
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDialog(title: String,
                    text: String,
                    style: UIAlertController.Style = .alert,
                    negativeText: String = R.string.localizable.no(),
                    negativeCallback: MessageCallback? = nil,
                    positiveText: String = R.string.localizable.yes(),
                    positiveCallback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: style)
        
        alertController.addAction(UIAlertAction(title: negativeText, style: .cancel) { _ in
            negativeCallback?()
        })
        
        alertController.addAction(UIAlertAction(title: positiveText, style: .default) { _ in
            positiveCallback?()
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDialog(title: String,
                    text: String,
                    style: UIAlertController.Style = .alert,
                    actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title,
                                                message: text,
                                                preferredStyle: style)
        
        actions.forEach { alertController.addAction($0) }
        
        alertController.popoverPresentationController?.sourceView = view
        
        present(alertController, animated: true, completion: nil)
    }
    
}
