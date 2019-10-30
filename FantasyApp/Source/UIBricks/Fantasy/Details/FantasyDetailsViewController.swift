//
//  FantasyDetailsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension Fantasy {
    struct LayoutConstants {
        static let cardAspectRatio: CGFloat = 375.0 / 560.0
        static let minCornerRadius: CGFloat = 12.0
        static let backgroundImageMargin: CGFloat = 26.0
        static let minBackgroundImageMargin: CGFloat = 16.0
    }
}

class FantasyDetailsViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyDetailsViewModel!

    override var prefersNavigationBarHidden: Bool {
        return true
    }

    var isZoomed: Bool {
        return scrollView.contentOffset.y == 0 &&
            backgroundImageLeftMargin.constant == Fantasy.LayoutConstants.minBackgroundImageMargin &&
            backgroundImageRightMargin.constant == Fantasy.LayoutConstants.minBackgroundImageMargin
    }

    static let initialScrollViewRatio: CGFloat = 1 / 3

    // MARK: - Outlets
    // TODO: Combine like+dislike+labels into one separate UI component
    @IBOutlet private (set) var navigationBar: UINavigationBar!
    @IBOutlet private (set) var titleLabel: UILabel!
    @IBOutlet private (set) var gradientBackgroundView: UIView!
    @IBOutlet private (set) var backgroundView: UIView!
    @IBOutlet private (set) var scrollView: UIScrollView!
    @IBOutlet private (set) var stackView: FantasyStackView!
    @IBOutlet private (set) var backgroundImageView: UIImageView!
    @IBOutlet private (set) var descriptionView: UIView!
    @IBOutlet private (set) var descriptionTitleLabel: UILabel!
    @IBOutlet private (set) var descriptionLabel: UILabel!
    @IBOutlet private (set) var descriptionButton: UIButton!
    @IBOutlet private (set) var likeButton: UIButton!
    @IBOutlet private (set) var likeLabel: UILabel!
    @IBOutlet private (set) var likesCountLabel: UILabel!
    @IBOutlet private (set) var dislikeButton: UIButton!
    @IBOutlet private (set) var dislikeLabel: UILabel!
    @IBOutlet private (set) var dislikesCountLabel: UILabel!
    @IBOutlet private (set) var preferenceView: UIView!
    @IBOutlet private (set) var preferenceTitleLabel: UILabel!
    @IBOutlet private (set) var collectionsView: UIView!
    @IBOutlet private (set) var collectionsTitleLabel: UILabel!
    @IBOutlet private (set) var collectionView: UICollectionView!
    @IBOutlet private (set) var shareButton: UIButton!
    @IBOutlet private (set) var closeButton: UIButton!
    @IBOutlet private (set) var optionButton: UIButton!

    @IBOutlet private (set) var backgroundImageLeftMargin: NSLayoutConstraint!
    @IBOutlet private (set) var backgroundImageRightMargin: NSLayoutConstraint!
    @IBOutlet private (set) var backgroundImageCenterY: NSLayoutConstraint!
    @IBOutlet private (set) var equalButtonsWidth: NSLayoutConstraint!
    @IBOutlet private (set) var likeSelectedWidth: NSLayoutConstraint!
    @IBOutlet private (set) var dislikeSelectedWidth: NSLayoutConstraint!
    @IBOutlet private (set) var collapsedDescriptionHeight: NSLayoutConstraint!
    @IBOutlet private (set) var zoomedBackgroundConstratint: NSLayoutConstraint!
    @IBOutlet private (set) var unzoomedBackgroundConstratint: NSLayoutConstraint!

    private var isZoomingBlocked = false
    private var isFirstAppearance = true

    lazy var collectionsDataSource = RxCollectionViewSectionedAnimatedDataSource
    <AnimatableSectionModel<String, Fantasy.Collection>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in
            let cell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                     for: indexPath)!

            cell.fantasiesCount = model.cardsCount
            cell.imageURL = model.imageURL
            cell.title = model.title
            cell.isPaid = model.productId != nil

            return cell
        }
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        ImageRetreiver.imageForURLWithoutProgress(url: viewModel!.imageURL)
                   .drive(backgroundImageView.rx.image)
                   .disposed(by: backgroundImageView.rx.disposeBag)

        viewModel.currentState.asDriver().drive(onNext: { [weak self] reaction in
            self?.configurePreferenceState(reaction)
        }).disposed(by: rx.disposeBag)

        viewModel.collectionsDataSource.map { [weak self] model in
            self?.collectionsView.isHidden = (model.first?.items.count ?? 0) == 0
            return model
        }
        .drive(collectionView.rx.items(dataSource: collectionsDataSource))
        .disposed(by: rx.disposeBag)

        collectionView.rx
            .modelSelected(Fantasy.Collection.self)
            .subscribe(onNext: { [unowned self] (x) in
                self.viewModel.show(collection: x)
            })
            .disposed(by: rx.disposeBag)
            
        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeOnSwipe))
        swipeRecognizer.direction = .down
        swipeRecognizer.delegate = self
        view.addGestureRecognizer(swipeRecognizer)

        configureStyling()
        configurePreferenceState(viewModel.currentState.value)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard isFirstAppearance else { return }
        animateAppearance()
        isFirstAppearance = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard isFirstAppearance else { return }
        descriptionView.isHidden = viewModel.description.isEmpty
        descriptionLabel.text = viewModel.description
        descriptionButton.isHidden = !descriptionLabel.isTruncated
    }
}

// MARK: - Configuration
private extension FantasyDetailsViewController {
    func configureStyling() {
        navigationBar.applyFantasyStyling()
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        gradientBackgroundView.isHidden = true
        gradientBackgroundView.addFantasyGradient()
        view.backgroundColor = .clear
        backgroundView.backgroundColor = .fantasyCardBackground
        backgroundView.isHidden = true
        stackView.isHidden = true
        closeButton.alpha = 0.0
        optionButton.alpha = 0.0
        titleLabel.alpha = 0.0

        backgroundImageView.contentMode = .scaleAspectFill

        stackView.backgroundColor = .fantasyLightGrey

        [descriptionView,
         preferenceView,
         collectionsView].forEach { $0?.layer.cornerRadius = 16.0 }

        backgroundImageView.layer.cornerRadius = 25.0

        [descriptionButton,
         likeButton,
         dislikeButton,
         shareButton].forEach { $0?.layer.cornerRadius = ($0?.frame.height ?? 0.0) / 2.0 }

        titleLabel.text = R.string.localizable.fantasyCardTitle()
        titleLabel.textColor = .title
        titleLabel.font = .boldFont(ofSize: 18)

        descriptionTitleLabel.text = R.string.localizable.fantasyCardStoryTitle()
        descriptionTitleLabel.textColor = .fantasyBlack
        descriptionTitleLabel.font = .boldFont(ofSize: 25)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .fantasyBlack
        descriptionLabel.font = .regularFont(ofSize: 15)

        descriptionButton.setTitle(R.string.localizable.fantasyCardReadMoreButton(), for: .normal)
        descriptionButton.setTitle(R.string.localizable.fantasyCardShowLessButton(), for: .selected)
        descriptionButton.backgroundColor = .fantasyLightGrey
        descriptionButton.setTitleColor(.fantasyPink, for: .normal)
        descriptionButton.titleLabel?.font = .boldFont(ofSize: 14)

        preferenceTitleLabel.text = R.string.localizable.fantasyCardPreferenceTitle()
        preferenceTitleLabel.textColor = .fantasyBlack
        preferenceTitleLabel.font = .boldFont(ofSize: 25)

        likeButton.setTitle(R.string.localizable.fantasyCardLikeButton(), for: .normal)
        likeButton.backgroundColor = .fantasyLightGrey
        likeButton.setTitleColor(.fantasyPink, for: .normal)
        likeButton.titleLabel?.font = .boldFont(ofSize: 16)

        dislikeButton.setTitle(R.string.localizable.fantasyCardDislikeButton(), for: .normal)
        dislikeButton.backgroundColor = .fantasyLightGrey
        dislikeButton.setTitleColor(.fantasyPink, for: .normal)
        dislikeButton.titleLabel?.font = .boldFont(ofSize: 16)

        collectionsTitleLabel.text = R.string.localizable.fantasyCardCollectionsTitle()
        collectionsTitleLabel.textColor = .fantasyBlack
        collectionsTitleLabel.font = .boldFont(ofSize: 25)

        shareButton.setTitle(R.string.localizable.fantasyCardShareButton(), for: .normal)
        shareButton.backgroundColor = .fantasyGrey
        shareButton.setTitleColor(.fantasyPink, for: .normal)
        shareButton.titleLabel?.font = .boldFont(ofSize: 16)

        likeLabel.text = R.string.localizable.fantasyCardLikedTitle()
        likeLabel.textColor = .fantasyPink
        likeLabel.font = .boldFont(ofSize: 16)

        dislikeLabel.text = R.string.localizable.fantasyCardDislikedTitle()
        dislikeLabel.textColor = .fantasyPink
        dislikeLabel.font = .boldFont(ofSize: 16)

        dislikesCountLabel.text = R.string.localizable.fantasyCardPreferenceCountTitle(viewModel.dislikesCount)
        dislikesCountLabel.textColor = .fantasyBlack
        dislikesCountLabel.font = .regularFont(ofSize: 16)

        likesCountLabel.text = R.string.localizable.fantasyCardPreferenceCountTitle(viewModel.likesCount)
        likesCountLabel.textColor = .fantasyBlack
        likesCountLabel.font = .regularFont(ofSize: 16)
    }

    func configurePreferenceState(_ reaction: Fantasy.Card.Reaction) {
        switch reaction {
        case .like:
            dislikeLabel.isHidden = true
            dislikesCountLabel.isHidden = true
        case .dislike:
            likeLabel.isHidden = true
            likesCountLabel.isHidden = true
        default:
            dislikeLabel.isHidden = true
            dislikesCountLabel.isHidden = true
            likeLabel.isHidden = true
            likesCountLabel.isHidden = true
        }

        likeButton.setTitle(reaction == .neutral ? R.string.localizable.fantasyCardLikeButton() : "",
                            for: .normal)
        likeButton.backgroundColor = reaction == .like ? .preferenceButtonSelected : .fantasyLightGrey

        dislikeButton.setTitle(reaction == .neutral ? R.string.localizable.fantasyCardDislikeButton() : "",
                               for: .normal)
        dislikeButton.backgroundColor = reaction == .dislike ? .preferenceButtonSelected : .fantasyLightGrey

        animatePreferenceChange(reaction)
    }
}

// MARK: - Actions
private extension FantasyDetailsViewController {
    @IBAction func likeCard(_ sender: Any) {
        viewModel.likeCard()
    }

    @IBAction func dislikeCard(_ sender: Any) {
        viewModel.dislikeCard()
    }

    @IBAction func close(_ sender: Any) {
        if isZoomed {
            isZoomingBlocked = false
            animateUnzoom()
            configureNavigationBarButtons()
        } else {
            animateDisappearance()
        }
    }

    @IBAction func zoomCard(_ sender: Any) {
        isZoomingBlocked = true
        animateZoom()
        configureNavigationBarButtons()
    }

    @IBAction func expandOrCollapseStory(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            collapsedDescriptionHeight.isActive = false
        } else {
            collapseStoryAnimated()
        }
    }
}

// MARK: - Scrolling
extension FantasyDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureNavigationBarButtons()
        configureBackground()

        guard !isZoomingBlocked else { return }

        configureCardLayout()
    }

    private func configureNavigationBarButtons() {
        if isZoomed {
            closeButton.setImage(R.image.cardDetailsClose(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        } else if scrollView.contentOffset.y >= scrollView.bounds.height *
            unzoomedBackgroundConstratint.multiplier - navigationBar.frame.maxY {
            closeButton.setImage(R.image.navigationBackButton(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOptionPlain(), for: .normal)
        } else {
            closeButton.setImage(R.image.cardDetailsBack(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        }
    }

    private func configureBackground() {
        let minY = scrollView.bounds.height * unzoomedBackgroundConstratint.multiplier - navigationBar.frame.maxY
        if scrollView.contentOffset.y >= minY {
            gradientBackgroundView.isHidden = false
        } else {
            gradientBackgroundView.isHidden = true
        }
    }

    private func configureCardLayout() {
        let cap = UIScreen.main.bounds.height * FantasyDetailsViewController.initialScrollViewRatio
        if scrollView.contentOffset.y < cap {
            backgroundImageCenterY.constant = min(0, scrollView.contentOffset.y - cap +
                backgroundImageView.frame.height / 3)
        }
    }
}

// MARK: - Swipe to close
extension FantasyDetailsViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    @objc func closeOnSwipe() {
        if scrollView.contentOffset.y == 0 {
            animateDisappearance()
        }
    }
}
