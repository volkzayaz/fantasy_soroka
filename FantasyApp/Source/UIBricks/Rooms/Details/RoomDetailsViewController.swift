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
                
        viewModel.navigationEnabled
            .drive(onNext: { [unowned self] (x) in
                self.playButton.isEnabled = x
                self.fantasiesButton.isEnabled = x
                self.chatButton.isEnabled = x
                
                self.navigationItem.rightBarButtonItem?.isEnabled = x
            })
            .disposed(by: rx.disposeBag)


        Driver.combineLatest(
        ImageRetreiver.imageForURLWithoutProgress(url: viewModel.room.value.me.userSlice.avatarURL)
            .map { $0 ?? R.image.noPhoto() },
        ImageRetreiver.imageForURLWithoutProgress(url: viewModel.room.value.peer.userSlice.avatarURL)
            .map { $0 ?? R.image.noPhoto() })
            .drive(onNext: { [unowned self] (images) in

                let v = R.nib.roomDetailsTitlePhotoView(owner: self)!
                v.leftImageView.image = images.0                
                v.rightImageView.image = images.1
                v.delegate = self
                self.navigationItem.titleView = v

            }).disposed(by: rx.disposeBag)



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
                                                                               reactionCallback: nil,
                                                                               navigationContext: .RoomMutual)
                                                },
                                                titleProvider: { count in
                                                    
                                                    let text: String
                                                    if count == 0 {
                                                        text = "Swipe to see new\nmutual Fantasies!\nYou have no mutual Fantasies yet"
                                                    }
                                                    else if count == 1 {
                                                        text = "1 mutual Fantasy"
                                                    }
                                                    else {
                                                        text = "\(count) mutual Fantasies"
                                                    }
                                                    
                                                    let att = NSMutableAttributedString(string: text, attributes: [.font: UIFont.boldFont(ofSize: 25)])
                                                    
                                                    if let range = text.range(of: "\(count)") {
                                                        att.addAttributes([.foregroundColor : R.color.textPinkColor()!],
                                                                          range: text.nsRange(from: range))
                                                    }
                                                    
                                                    if let range = text.range(of: "You have no mutual Fantasies yet") {
                                                        
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
                                                protectPolicy: User.changesOfSubscriptionStatus)
            
        }
        else if segue.identifier == R.segue.roomDetailsViewController.showChat.identifier {
            
            let vc = segue.destination as! ChatViewController
            vc.viewModel = ChatViewModel(router: .init(owner: vc),
                                         room: viewModel.room)
            
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
