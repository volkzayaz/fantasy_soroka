//
//  RoomDetailsViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomDetailsViewController: UIViewController, MVVM_View {
    var viewModel: RoomDetailsViewModel!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var fantasiesButton: PrimaryButton!
    @IBOutlet private var chatButton: PrimaryButton!
    @IBOutlet private var playButton: PrimaryButton!
    @IBOutlet private var chatContainerView: UIView!
    @IBOutlet private var commonFantasiesContainerView: UIView!
    
    private var gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        viewModel.page.asDriver().drive(onNext: { [weak self] page in
            self?.selectPage(page)
        }).disposed(by: rx.disposeBag)
        
        navigationItem.title = viewModel.title
        
        viewModel.navigationEnabled
            .drive(onNext: { [unowned self] (x) in
                self.playButton.isEnabled = x
                self.fantasiesButton.isEnabled = x
                self.chatButton.isEnabled = x
                
                self.navigationItem.rightBarButtonItem?.isEnabled = x
            })
            .disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectPage(viewModel.page.value, animated: false)
        scrollView.isHidden = false
    }

}

extension RoomDetailsViewController {
    func configure() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.roomDetailsSettings(),
                                                            style: .plain,
                                                            target: self, action: Selector("showActions"))
        
        chatButton.setTitle(R.string.localizable.roomDetailsChat(), for: .normal)
        chatButton.mode = .selector
        playButton.setTitle(R.string.localizable.roomDetailsPlay(), for: .normal)
        playButton.mode = .selector
        fantasiesButton.setTitle(R.string.localizable.roomDetailsFantasies(), for: .normal)
        fantasiesButton.mode = .selector

        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.gradient3.cgColor,
                                UIColor.gradient2.cgColor,
                                UIColor.gradient1.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func selectPage(_ page: RoomDetailsViewModel.DetailsPage, animated: Bool = true) {
        
        commonFantasiesContainerView.subviews.first?.isHidden = false
        
        let rect = CGRect(x: scrollView.bounds.width * CGFloat(page.rawValue),
                          y: 0,
                          width: scrollView.bounds.width,
                          height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(rect, animated: animated)

        chatButton.isSelected = page == .chat
        fantasiesButton.isSelected = page == .fantasies
        
    }

    @objc func showActions() {
        viewModel.showSettins()
    }
    
    @IBAction func selectPage(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if sender == fantasiesButton {
            viewModel.page.accept(.fantasies)
        } else if sender == chatButton {
            viewModel.page.accept(.chat)
        } else {
            
            viewModel.showPlay()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.roomDetailsViewController.showCommonFantasies.identifier {
            
            let vc = segue.destination as! FantasyListViewController
            
            let room = viewModel.room.value
            let provider = viewModel.page
                .filter { $0 == .fantasies }
                .flatMapLatest { _ in
                    Fantasy.Manager.mutualCards(in: room)
                }
                .asDriver(onErrorJustReturn: [])
            
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: provider,
                                                title: "Mutual Fantasies")
            
        }
        else if segue.identifier == R.segue.roomDetailsViewController.showChat.identifier {
            
            let vc = segue.destination as! ChatViewController
            vc.viewModel = ChatViewModel(router: .init(owner: vc),
                                         room: viewModel.room, chattoDelegate: vc)
            
        }
        
    }
    
}
