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
    
    override func viewDidLoad() {
        inviteSheetView.layer.maskedCorners =  [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        viewModel.cancelPressed
            .asDriver()
            .drive(onNext: { [unowned self] x in
                UIView.animate(withDuration: x ? 0.3 : 1, delay: x ? 0 : 0.3, options: [.curveEaseOut]) {
                    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
                    if x {
                        self.view.backgroundColor = .clear
                    }
                }
            }).disposed(by: rx.disposeBag)
    }
}

//MARK: Actions
extension InviteSheetViewController {
    @IBAction func cancelPressed(_ sender: UIButton) {
        viewModel.cancelPressed.accept(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true) {
                self.viewModel
                    .fantasyDeckViewModel?.emptyPeerPressed
                    .accept(false)
                
                self.viewModel
                    .roomDetailsViewModel?.emptyPeerPressed
                    .accept(false)
            }
        }
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
    
    @IBAction func messengerViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.messengerViewAction()
    }
    
    @IBAction func moreViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.moreViewAction()
    }
}
