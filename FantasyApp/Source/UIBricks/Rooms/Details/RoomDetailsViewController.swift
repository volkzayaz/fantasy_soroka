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
    
    @IBOutlet private var fantasiesButton: PrimaryButton!
    @IBOutlet private var chatButton: PrimaryButton!
    @IBOutlet private var playButton: PrimaryButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var chatContainerView: UIView!
    @IBOutlet private var commonFantasiesContainerView: UIView!
    @IBOutlet private var playContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        viewModel.page.asDriver().drive(onNext: { [weak self] page in
            self?.selectPage(page)
        }).disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectPage(viewModel.page.value)
    }
}

private extension RoomDetailsViewController {
    func configure() {
        chatButton.setTitle(R.string.localizable.roomDetailsChat(), for: .normal)
        chatButton.mode = .selector
        playButton.setTitle(R.string.localizable.roomDetailsPlay(), for: .normal)
        playButton.mode = .selector
        fantasiesButton.setTitle(R.string.localizable.roomDetailsFantasies(), for: .normal)
        fantasiesButton.mode = .selector

        viewModel.router.embedChat(in: chatContainerView)
        viewModel.router.embedCommonFantasies(in: commonFantasiesContainerView)
        viewModel.router.embedPlay(in: playContainerView)
    }

    func selectPage(_ page: RoomDetailsViewModel.DetailsPage) {
        let rect = CGRect(x: scrollView.bounds.width * CGFloat(page.rawValue),
                          y: 0,
                          width: scrollView.bounds.width,
                          height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(rect, animated: true)

        chatButton.isSelected = page == .chat
        fantasiesButton.isSelected = page == .fantasies
        playButton.isSelected = page == .play
    }

    @IBAction func selectPage(_ sender: UIButton) {
        if sender == fantasiesButton {
            viewModel.page.accept(.fantasies)
        } else if sender == chatButton {
            viewModel.page.accept(.chat)
        } else {
            viewModel.page.accept(.play)
        }
    }
}
