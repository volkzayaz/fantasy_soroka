//
//  RoomDetailsViewController.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

class RoomDetailsViewController: UIViewController, MVVM_View {
    var viewModel: RoomDetailsViewModel!
    @IBOutlet private var fantasiesButton: PrimaryButton!
    @IBOutlet private var chatButton: PrimaryButton!
    @IBOutlet private var playButton: PrimaryButton!
    @IBOutlet private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        viewModel.page.asDriver().drive(onNext: { [weak self] page in
            self?.selectPage(page)
        }).disposed(by: rx.disposeBag)
    }
}

private extension RoomDetailsViewController {
    func configure() {
        chatButton.setTitle(R.string.localizable.roomDetailsChat(), for: .normal)
        playButton.setTitle(R.string.localizable.roomDetailsPlay(), for: .normal)
        fantasiesButton.setTitle(R.string.localizable.roomDetailsFantasies(), for: .normal)
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
}
