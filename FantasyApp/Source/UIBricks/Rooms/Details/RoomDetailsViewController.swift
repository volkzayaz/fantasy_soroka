//
//  RoomDetailsViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RoomDetailsViewController: UIViewController, MVVM_View {
    var viewModel: RoomDetailsViewModel!
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var fantasiesButton: PrimaryButton! {
        didSet {
            fantasiesButton.useTransparency = false
        }
    }
    @IBOutlet private var chatButton: PrimaryButton!{
        didSet {
            chatButton.useTransparency = false
        }
    }
    @IBOutlet private var playButton: PrimaryButton!{
        didSet {
            playButton.useTransparency = false
        }
    }
    @IBOutlet private var chatContainerView: UIView!
    @IBOutlet private var commonFantasiesContainerView: UIView!
    @IBOutlet private var playContainerView: UIView!
    @IBOutlet weak var inviteButton: SecondaryButton! {
        didSet { inviteButton.setTitle(R.string.localizable.roomsAddNewRoom(), for: .normal) }
    }
    
    private var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        viewModel.inviteButtonHidden
            .drive(inviteButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.page.asDriver().drive(onNext: { [weak self] page in
            self?.selectPage(page)
        }).disposed(by: rx.disposeBag)
                
        viewModel.navigationEnabled
            .drive(onNext: { [unowned self] (x) in
                self.playButton.isEnabled = x
                self.fantasiesButton.isEnabled = x
                self.chatButton.isEnabled = x
                
                self.navigationItem.rightBarButtonItem?.isEnabled = x
            })
            .disposed(by: rx.disposeBag)

        viewModel.room
            .asDriver()
            .distinctUntilChanged(\.participants)
            .flatMapLatest { room -> Driver<(UIImage?, UIImage?)> in
        
                let rightDriver: Driver<UIImage?>
                if let x = room.peer.userSlice?.avatarURL {
                    rightDriver = ImageRetreiver.imageForURLWithoutProgress(url: x)
                        .map { $0 ?? R.image.noPhoto() }
                }
                else {
                    rightDriver = .just(R.image.plus())
                }
                
                return Driver.combineLatest(
                ImageRetreiver.imageForURLWithoutProgress(url: room.me.avatarURL)
                    .map { $0 ?? R.image.noPhoto() },
                    rightDriver)
                
            }
            .drive(onNext: { [unowned self] (images) in
                
                let v = R.nib.roomDetailsTitlePhotoView(owner: self)!
                
                v.leftImageView.image = images.0
                v.rightImageView.image = images.1
                v.delegate = self
                self.navigationItem.titleView = v
                
            }).disposed(by: rx.disposeBag)
        
        navigationItem.leftBarButtonItem = .init(image: R.image.back()!, style: .plain, target: self, action: #selector(_dismiss))
    }
    
    @objc func _dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectPage(viewModel.page.value, animated: false)
        scrollView.isHidden = false
        (navigationItem.titleView as? RoomDetailsTitlePhotoView)?.startAnimating()
    }
    
}

extension RoomDetailsViewController {
    func configure() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.roomDetailsSettings(),
                                                            style: .plain,
                                                            target: self, action: Selector("showActions"))
        
        chatButton.setTitle(R.string.localizable.roomDetailsChat(), for: .normal)
        chatButton.mode = .selector
        playButton.setTitle("Play", for: .normal)
        playButton.mode = .selector
        fantasiesButton.setTitle(R.string.localizable.roomDetailsFantasies(), for: .normal)
        fantasiesButton.mode = .selector
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.gradient3.cgColor,
                                UIColor.gradient2.cgColor,
                                UIColor.gradient1.cgColor]
        
        view.addFantasyGradient()
    }
    
    func selectPage(_ page: RoomDetailsViewModel.DetailsPage, animated: Bool = true) {
        
        let rect = CGRect(x: scrollView.bounds.width * CGFloat(page.rawValue),
                          y: 0,
                          width: scrollView.bounds.width,
                          height: scrollView.bounds.height)
        // Without async it does not work properly when an invite link is opened
        DispatchQueue.main.async {
            self.scrollView.scrollRectToVisible(rect, animated: animated)
        }

        chatButton.isSelected = page == .chat
        fantasiesButton.isSelected = page == .fantasies
        playButton.isSelected = page == .play
        
    }
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        viewModel.inviteButtonTapped()
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
            viewModel.page.accept(.play)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.roomDetailsViewController.showCommonFantasies.identifier {
            
            let vc = segue.destination as! FantasyListViewController
            
            let room = viewModel.room.value
            
            let left = viewModel.page
                .filter { $0 == .fantasies }
                .map { _ in }
            
            let right = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in }
            
            let provider = Observable.merge(left, right)
                .flatMapLatest { _ in
                    Fantasy.Manager.mutualCards(in: room)
                }
                .asDriver(onErrorJustReturn: [])
            
            vc.viewModel = FantasyListViewModel(router: .init(owner: vc),
                                                cardsProvider: provider,
                                                detailsProvider: { card in
                                                    RoomFantasyDetailsProvider(room: room,
                                                                               card: card,
                                                                               initialReaction: .like,
                                                                               navigationContext: .RoomMutual)
                                                },
                                                titleProvider: { count in
                                                    
                                                    
                                                    var text: String
                                                    if count == 0 {
                                                        
                                                        text = R.string.localizable.roomDetailsSwipeTitle()
                                                        
                                                    }
                                                    else if count == 1 {
                                                        text = R.string.localizable.roomDetailsOneMutualCard()
                                                    }
                                                    else {
                                                        text = R.string.localizable.roomDetailsMutualCards(count)
                                                    }
                                                    
                                                    let att = NSMutableAttributedString(string: text, attributes: [.font: UIFont.boldFont(ofSize: 25)])
                                                    
                                                    if let range = text.range(of: "\(count)") {
                                                        att.addAttributes([.foregroundColor : R.color.textPinkColor()!],
                                                                          range: text.nsRange(from: range))
                                                    }
                                                    
                                                    if let range = text.range(of: R.string.localizable.roomDetailsNoMutualCards()) {
                                                        
                                                        att.addAttributes([.foregroundColor : UIColor.gray],
                                                                          range: text.nsRange(from: range))
                                                        att.addAttributes([.font : UIFont.regularFont(ofSize: 15)],
                                                                          range: text.nsRange(from: range))
                                                        
                                                        let style = NSMutableParagraphStyle()
                                                        style.lineHeightMultiple = 1.5
                                                        att.addAttribute(.paragraphStyle, value: style,
                                                                         range: text.nsRange(from: range))
                                                    }
                                                    
                                                    return att
                                                    
                                                },
                                                roomDetailsVM: viewModel,
                                                protectPolicy: User.changesOfSubscriptionStatus,
                                                hideUnread: true)
            
        }
        
        else if segue.identifier == R.segue.roomDetailsViewController.showChat.identifier {
            
            let vc = segue.destination as! ChatViewController
            vc.viewModel = ChatViewModel(router: .init(owner: vc),
                                         room: viewModel.room)
            
        }
        else if segue.identifier == "embedPlay" {
            
            let vc = segue.destination as! FantasyDeckViewController
            vc.viewModel = .init(router: .init(owner: vc),
                                 provider: RoomsDeckProvider(room: viewModel.room.value),
                                 presentationStyle: .modal,
                                 room: viewModel.room,
                                 container: self)
            
        }

        
    }
    
}


//MARK:- RoomDetailsTitlePhotoViewDelegate

extension RoomDetailsViewController: RoomDetailsTitlePhotoViewDelegate {
    
    func didSelectedInitiator() {
        viewModel.presentMe()
    }
    
    func didSelectedPeer() {
        viewModel.presentPeer()
    }
    
}
