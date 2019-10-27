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
    @IBOutlet private var settingsButton: PrimaryButton!
    @IBOutlet private var fantasiesButton: PrimaryButton!
    @IBOutlet private var chatButton: PrimaryButton!
    @IBOutlet private var playButton: PrimaryButton!
    @IBOutlet private var settingsContainerView: UIView!
    @IBOutlet private var chatContainerView: UIView!
    @IBOutlet private var commonFantasiesContainerView: UIView!
    @IBOutlet private var playContainerView: UIView!
    private var gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        viewModel.page.asDriver().drive(onNext: { [weak self] page in
            self?.selectPage(page)
        }).disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectPage(viewModel.page.value, animated: false)
        scrollView.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingsContainerView.roundCorners([.topLeft, .topRight], radius: 20)
    }
}

extension RoomDetailsViewController {
    func configure() {
        settingsButton.setTitle(R.string.localizable.roomDetailsSettings(), for: .normal)
        settingsButton.mode = .selector
        chatButton.setTitle(R.string.localizable.roomDetailsChat(), for: .normal)
        chatButton.mode = .selector
        playButton.setTitle(R.string.localizable.roomDetailsPlay(), for: .normal)
        playButton.mode = .selector
        fantasiesButton.setTitle(R.string.localizable.roomDetailsFantasies(), for: .normal)
        fantasiesButton.mode = .selector

        viewModel.router.embedSettings(in: settingsContainerView)
        viewModel.router.embedChat(in: chatContainerView)
        viewModel.router.embedCommonFantasies(in: commonFantasiesContainerView)
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.gradient3.cgColor,
                                UIColor.gradient2.cgColor,
                                UIColor.gradient1.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func selectPage(_ page: RoomDetailsViewModel.DetailsPage, animated: Bool = true) {
        let rect = CGRect(x: scrollView.bounds.width * CGFloat(page.rawValue),
                          y: 0,
                          width: scrollView.bounds.width,
                          height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(rect, animated: animated)

        settingsButton.isSelected = page == .settings
        chatButton.isSelected = page == .chat
        fantasiesButton.isSelected = page == .fantasies
        playButton.isSelected = page == .play
    }

    @IBAction func selectPage(_ sender: UIButton) {
        if sender == settingsButton {
            viewModel.page.accept(.settings)
        } else if sender == fantasiesButton {
            viewModel.page.accept(.fantasies)
        } else if sender == chatButton {
            viewModel.page.accept(.chat)
        } else {
            viewModel.page.accept(.play)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FantasiesViewController" {
            
            let vc = segue.destination as! FantasyDeckViewController
            vc.viewModel = FantasyDeckViewModel(router: .init(owner: vc),
                                                provider: RoomsDeckProvider(room: viewModel.room))
            
        }
        
    }
    
}
