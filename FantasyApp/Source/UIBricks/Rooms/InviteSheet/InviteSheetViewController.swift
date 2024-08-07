//
//  InviteSheetViewController.swift
//  FantasyApp
//
//  Created by Максим Сорока on 22.02.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InviteSheetViewController: UIViewController, MVVM_View {
    var viewModel: InviteSheetViewModel!
    
    @IBOutlet weak var inviteSheetView: UIView!
    @IBOutlet weak var copiedImage: UIImageView! {
        didSet {
            copiedImage.alpha = 0
        }
    }
    
    override func viewDidLoad() {
        inviteSheetView.layer.maskedCorners =  [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        viewModel.cancelPressed
            .asDriver()
            .drive(onNext: { [unowned self] x in
                UIView.animate(withDuration: x ? 0.1 : 0.3, delay: x ? 0 : 0.35, options: [.curveEaseOut]) {
                    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
                    if x {
                        self.view.backgroundColor = .clear
                    }
                } completion: { (_) in
                    if x { self.dismiss(animated: true) }
                }
            }).disposed(by: rx.disposeBag)
        
        
        viewModel.flashCopied
            .subscribe(onNext: { [weak self] (_) in
                
                UIView.animate(withDuration: 0.4) {
                    self?.copiedImage.alpha = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        UIView.animate(withDuration: 0.4) {
                            self?.copiedImage.alpha = 0
                            self?.viewModel.cancelPressed.accept(true)
                        }
                        
                    }
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    @IBAction func dismisssTap(_ sender: Any) {
        viewModel.cancelPressed.accept(true)
    }
}

//MARK: Actions
extension InviteSheetViewController {
    @IBAction func cancelPressed(_ sender: UIButton) {
        viewModel.cancelPressed.accept(true)

    }
    
    @IBAction func copyLinkViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.copyLinkViewAction()
    }
    
    @IBAction func SMSViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.SMSViewAction()
    }
    
    @IBAction func whatsAppViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.whatsAppViewAction()
    }
    
    @IBAction func moreViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.moreViewAction()
    }
}
