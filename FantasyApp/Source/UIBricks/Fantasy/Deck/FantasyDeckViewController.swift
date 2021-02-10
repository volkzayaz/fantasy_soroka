//
//  FantasyDeckViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import Koloda
import RxSwift
import RxCocoa
import RxDataSources

class FantasyDeckViewController: UIViewController, MVVM_View {

    enum PresentationStyle {
        case modal
        case stack
    }
    
    private var animator = FantasyDetailsTransitionAnimator()

    lazy var viewModel: FantasyDeckViewModel! = .init(router: .init(owner: self))

    @IBOutlet weak var tableView: UITableView!

    private var tutorialView: FantasyDeckTutorialView?
    @IBOutlet weak var mutualCardContainer: UIView! {
        didSet {
            mutualCardContainer.alpha = 0
        }
    }
    @IBOutlet weak var tinyCardImageView: UIImageView!
    
    @IBOutlet weak var fantasiesView: KolodaView! {
        didSet {
            fantasiesView.dataSource = self
            fantasiesView.countOfVisibleCards = 3
            fantasiesView.delegate = self
            fantasiesView.backgroundCardsTopMargin = 0
            fantasiesView.isHidden = true
        }
    }
    
    @IBOutlet weak var addImageView: UIImageView! {
        didSet {
            addImageView.image = addImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet weak var addDeckView: UIView!

    @IBOutlet weak var waitingView: UIView! {
        didSet { waitingView.isHidden = true }
    }

    @IBOutlet weak var cardsView: UIView!
    
    @IBOutlet weak var timeLimitDecsriptionLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var subsbcriptionLabel: UILabel!
    @IBOutlet weak var subscribeButton: SecondaryButton!
    @IBOutlet weak var cardsButton: PrimaryButton! {
        didSet {
            cardsButton.useTransparency = false
            cardsButton.setTitleColor(UIColor.fantasyPink, for: .selected)
            cardsButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    @IBOutlet weak var collectionsButton: PrimaryButton! {
        didSet {
            collectionsButton.useTransparency = false
            collectionsButton.setTitleColor(UIColor.fantasyPink, for: .selected)
            collectionsButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    
    lazy var sectionsTableDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, [Fantasy.Collection]>>(configureCell: { [unowned self] (_, tv, ip, category) in

            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.categoryFantasies, for: ip)!
        
            cell.decksCountLabel.text = category.count == 1 ? "deck" : "decks"
            cell.categoryName.text = category.first?.category
            cell.numberDecks.text = "\(category.count)"
            cell.fantasyDeckViewModel = self.viewModel

            cell.bindModel(x: category)
           
            return cell
    })
    

    ///TODO: refactor to RxColodaDatasource
    private var cardsProxy: [Fantasy.Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.isPlayRoomPage.drive(onNext: { [unowned self]  x in
            tableView.isHidden = x
        }).disposed(by: rx.disposeBag)
        
        viewModel.mode.drive(onNext: { [unowned self] mode in
            self.waitingView.isHidden = mode == .swipeCards
            self.fantasiesView.isHidden = mode == .waiting
        }).disposed(by: rx.disposeBag)
        
        viewModel.timeLeftText
            .drive(timeLeftLabel.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        
        viewModel.cards.drive(onNext: { [unowned self] (newState) in
            let from = self.fantasiesView.currentCardIndex
            let internalState = self.cardsProxy.suffix(from: from)

            guard internalState.count == newState.count else {
                self.cardsProxy = newState
                self.fantasiesView.resetCurrentCardIndex()
                return
            }

            for (new, old) in zip(newState, internalState) where new != old {
                self.cardsProxy = newState
                self.fantasiesView.resetCurrentCardIndex()
                return
            }
                
        }).disposed(by: rx.disposeBag)

        viewModel.mutualCardTrigger.drive(onNext: { [unowned self] (x) in
            let url = x.imageURL

            ImageRetreiver.imageForURLWithoutProgress(url: url)
                .drive(self.tinyCardImageView.rx.image)
                .disposed(by: self.tinyCardImageView.rx.disposeBag)

            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.mutualCardContainer.alpha = 1

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    UIView.animate(withDuration: 0.5) {
                        self?.mutualCardContainer.alpha = 0
                    }
                }
            }
        }).disposed(by: rx.disposeBag)


        // tutorial
        viewModel.showTutorial
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] (show) in

                guard show else {
                    self.tutorialView?.removeFromSuperview()
                    self.tutorialView = nil
                    return
                }

                let v = FantasyDeckTutorialView.instance
                v.tutorialComplited = {
                    v.removeFromSuperview()
                    self.viewModel.updateTutorial(showNextTime: false)
                }

                self.view.addSubview(v)

                v.snp.makeConstraints { make in
                    make.edges.equalTo(self.fantasiesView)
                }

                self.tutorialView = v
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.sortedFantasies
            .map { $0.map { SectionModel(model: "", items: [$0]) } }
            .drive(tableView.rx.items(dataSource: sectionsTableDataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.subscribeButtonHidden
            .drive(subscribeButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.subscribeButtonHidden
            .drive(subsbcriptionLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        
        configureStyling()

        if viewModel.presentationStyle == .modal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.cardDetailsBack()!, style: .plain, target: self, action: #selector(dismissModal))
        }

        if let room = viewModel.room?.value {

            let rightDriver: Driver<UIImage?>
            if let x = room.peer.userSlice?.avatarURL {
                rightDriver = ImageRetreiver.imageForURLWithoutProgress(url: x)
                    .map { $0 ?? R.image.noPhoto() }
            }
            else {
                rightDriver = .just(R.image.add())
            }
            
            Driver.combineLatest(
                ImageRetreiver.imageForURLWithoutProgress(url: room.me.avatarURL)
                    .map { $0 ?? R.image.noPhoto() },
                rightDriver)
                .drive(onNext: { [unowned self] (images) in

                    let v = R.nib.roomDetailsTitlePhotoView(owner: self)!
                    v.leftImageView.image = images.0
                    v.rightImageView.image = images.1
                    v.delegate = self
                    self.navigationItem.titleView = v

                }).disposed(by: rx.disposeBag)
        }
    }

}

extension FantasyDeckViewController {

    // MARK: - Actions

    @objc func dismissModal() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapAddDeckImage(_ sender: Any) {
        if fantasiesView.isRunOutOfCards {
            viewModel.addCollection()
        }
        
    }

    @IBAction func subscribeTapped(_ sender: Any) {
        viewModel.subscribeTapped()
    }

    @IBAction func cardsTapped() {
        collectionsButton.isSelected = false
        cardsButton.isSelected = true
        cardsView.isHidden = false
        

        tutorialView?.isHidden = false
    }

    @IBAction func collectionsTapped() {
//        collectionsButton.isSelected = true
//        cardsButton.isSelected = false
        cardsView.isHidden = true
       

        tutorialView?.isHidden = true
    }

    // MARK: - Configuration
    func configureStyling() {
        navigationItem.title = R.string.localizable.fantasyDeckTitle()
        
        view.addFantasyGradient()

//        collectionsButton.setTitle(R.string.localizable.fantasyDeckCollectionsButton(), for: .normal)
//        collectionsButton.mode = .selector
//        collectionsButton.isSelected = false
//        cardsButton.setTitle(R.string.localizable.fantasyDeckCardsButton(), for: .normal)
//        cardsButton.mode = .selector
//        cardsButton.isSelected = true

        waitingView.addFantasyRoundedCorners()
        waitingView.backgroundColor = .primary

        timeLeftLabel.font = .boldFont(ofSize: 18)
        timeLeftLabel.numberOfLines = 0
        timeLeftLabel.textColor = .fantasyBlack

      

        timeLimitDecsriptionLabel.text = R.string.localizable.fantasyDeckTimeLimitDescription()
        timeLimitDecsriptionLabel.font = .boldFont(ofSize: 18)
        timeLimitDecsriptionLabel.textColor = .fantasyBlack
        timeLimitDecsriptionLabel.numberOfLines = 0

        subscribeButton.setTitle(R.string.localizable.fantasyDeckSubscriptionButton(), for: .normal)

        subsbcriptionLabel.text = R.string.localizable.fantasyDeckSubscriptionLabel()
        subsbcriptionLabel.font = .regularFont(ofSize: 15)
        subsbcriptionLabel.textColor = .basicGrey
                
        if RemoteConfigManager.learnDefaultScreen == .decks && viewModel.room == nil  {
            collectionsTapped()
        }
    }
}

extension FantasyDeckViewController: KolodaViewDataSource, KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return FantasyDeckItemOverlayView()
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = cardsProxy[index]
        let view = FantasyDeckItemView(frame: koloda.bounds)
        view.hasStory = !card.story.isEmpty
        view.isPaid = card.isPaid
        view.imageURL = card.imageURL
        
        view.card = card
        view.viewModel = viewModel
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return cardsProxy.count
    }
 
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        guard let card = cardsProxy[safe: index] else {
            ///because we don't use Rx it is possible
            ///that cardsProxy is desynchronised with actual datasource
            ///that is backing Koloda
            return
        }
        
        if case .left = direction {
            viewModel.swiped(card: card, direction: .left)
        } else if case .right = direction {
            viewModel.swiped(card: card, direction: .right)
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        
        guard let card = cardsProxy[safe: index] else {
            ///because we don't use Rx it is possible
            ///that cardsProxy is desynchronised with actual datasource
            ///that is backing Koloda
            return
        }
        
        viewModel.cardShown(card: card)
        
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let card = cardsProxy[index]
        viewModel.cardTapped(card: card)
    }
    
}

extension FantasyDeckViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false

        if let view = fantasiesView.viewForCard(at: self.fantasiesView.currentCardIndex) as? FantasyDeckItemView {
            view.animateAppearance()
        }

        return animator
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.originFrame = fantasiesView.superview?.convert(fantasiesView.frame, to: nil) ?? .zero
        animator.presenting = true

        if let view = fantasiesView.viewForCard(at: self.fantasiesView.currentCardIndex) as? FantasyDeckItemView {
            view.animateDisappearance()
        }
        
        return animator
    }
}

//MARK:- RoomDetailsTitlePhotoViewDelegate

extension FantasyDeckViewController: RoomDetailsTitlePhotoViewDelegate {
     func didSelectedInitiator() {
        viewModel.presentMe()
    }

    func didSelectedPeer() {
        viewModel.presentPeer()
    }
}
