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
    @IBOutlet private (set) var preferenceSelector: FantasyDetailsPreferenceSelector!
    @IBOutlet private (set) var preferenceView: UIView!
    @IBOutlet private (set) var preferenceTitleLabel: UILabel!
    @IBOutlet private (set) var collectionsView: UIView!
    @IBOutlet private (set) var collectionsTitleLabel: UILabel!
    @IBOutlet private (set) var collectionView: UICollectionView!
    @IBOutlet private (set) var shareButton: SecondaryButton!
    @IBOutlet private (set) var closeButton: UIButton!
    @IBOutlet private (set) var optionButton: UIButton!

    @IBOutlet private (set) var backgroundImageLeftMargin: NSLayoutConstraint!
    @IBOutlet private (set) var backgroundImageRightMargin: NSLayoutConstraint!
    @IBOutlet private (set) var backgroundImageCenterY: NSLayoutConstraint!
    @IBOutlet private (set) var collapsedDescriptionHeight: NSLayoutConstraint!
    @IBOutlet private (set) var zoomedBackgroundConstraint: NSLayoutConstraint!
    @IBOutlet private (set) var unzoomedBackgroundConstraint: NSLayoutConstraint!

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
            self?.preferenceSelector.reaction = reaction
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
        
        preferenceSelector.didPressLike = { [weak self] in
            self?.viewModel.likeCard()
        }
        
        preferenceSelector.didPressDislike = { [weak self] in
            self?.viewModel.dislikeCard()
        }
        preferenceSelector.likesCount = viewModel.likesCount
        preferenceSelector.dislikesCount = viewModel.dislikesCount
            
        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeOnSwipe))
        swipeRecognizer.direction = .down
        swipeRecognizer.delegate = self
        view.addGestureRecognizer(swipeRecognizer)

        configureBackgroundConstratints()
        configureStyling()
        preferenceSelector.reaction = viewModel.currentState.value
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
        shareButton.alpha = 0.0

        backgroundImageView.contentMode = .scaleAspectFill

        stackView.backgroundColor = .fantasyLightGrey

        [descriptionView,
         preferenceView,
         collectionsView].forEach { $0?.layer.cornerRadius = 16.0 }

        backgroundImageView.layer.cornerRadius = 25.0

        descriptionButton.layer.cornerRadius = descriptionButton.frame.height / 2.0 

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

        collectionsTitleLabel.text = R.string.localizable.fantasyCardCollectionsTitle()
        collectionsTitleLabel.textColor = .fantasyBlack
        collectionsTitleLabel.font = .boldFont(ofSize: 25)

        shareButton.setTitle(R.string.localizable.fantasyCardShareButton(), for: .normal)
    }
    
    func configureBackgroundConstratints() {
        let cardHeight = (view.bounds.width - (2 * Fantasy.LayoutConstants.backgroundImageMargin)) /
            Fantasy.LayoutConstants.cardAspectRatio
        zoomedBackgroundConstraint.constant = view.bounds.height
        unzoomedBackgroundConstraint.constant = view.bounds.height - (
            view.bounds.height - cardHeight - 50)
    }
}

// MARK: - Actions
private extension FantasyDetailsViewController {
    @IBAction func close(_ sender: Any) {
        if isZoomed {
            isZoomingBlocked = false
            scrollView.isScrollEnabled = true
            animateUnzoom()
            configureNavigationBarButtons()
        } else {
            animateDisappearance()
        }
    }

    @IBAction func zoomCard(_ sender: Any) {
        isZoomingBlocked = true
        scrollView.isScrollEnabled = false
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let areaRadius = view.bounds.height / 5
        let topAreaRange = 0 ... view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio - areaRadius
        let centerAreaRange = view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio - areaRadius ...
            view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio + areaRadius
        let bottomAreaRange = view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio + areaRadius ...
            scrollView.contentSize.height
        if centerAreaRange.contains(targetContentOffset.pointee.y) {
            targetContentOffset.pointee.y = view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio
            shareButton.isHidden = false
        } else if topAreaRange.contains(targetContentOffset.pointee.y) {
            targetContentOffset.pointee.y = 0
            shareButton.isHidden = true
        } else if bottomAreaRange.contains(targetContentOffset.pointee.y) {
            targetContentOffset.pointee.y = scrollView.contentSize.height - scrollView.bounds.height < 0 ? 0 :
                scrollView.contentSize.height - scrollView.bounds.height
            shareButton.isHidden = false
        }
    }

    private func configureNavigationBarButtons() {
        if isZoomed {
            closeButton.setImage(R.image.cardDetailsClose(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        } else if scrollView.contentOffset.y >=
            unzoomedBackgroundConstraint.constant - navigationBar.frame.maxY {
            closeButton.setImage(R.image.navigationBackButton(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOptionPlain(), for: .normal)
        } else {
            closeButton.setImage(R.image.cardDetailsBack(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        }
    }

    private func configureBackground() {
        if scrollView.contentOffset.y >=
            unzoomedBackgroundConstraint.constant - navigationBar.frame.maxY {
            gradientBackgroundView.isHidden = false
        } else {
            gradientBackgroundView.isHidden = true
        }
    }

    private func configureCardLayout() {
        let cap = view.bounds.height * FantasyDetailsViewController.initialScrollViewRatio
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
