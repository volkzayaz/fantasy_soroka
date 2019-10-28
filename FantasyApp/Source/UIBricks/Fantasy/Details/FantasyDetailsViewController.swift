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

class FantasyDetailsViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyDetailsViewModel!

    override var prefersNavigationBarHidden: Bool {
        return true
    }

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

    @IBOutlet private (set) var backgroundImageWidth: NSLayoutConstraint!
    @IBOutlet private (set) var backgroundImageHeight: NSLayoutConstraint!
    @IBOutlet private (set) var equalButtonsWidth: NSLayoutConstraint!
    @IBOutlet private (set) var likeSelectedWidth: NSLayoutConstraint!
    @IBOutlet private (set) var dislikeSelectedWidth: NSLayoutConstraint!
    @IBOutlet private (set) var collapsedDescriptionHeight: NSLayoutConstraint!

    static let minBackgroundImageWidth: CGFloat = 323.0
    static let minBackgroundImageHeight: CGFloat = 482.0
    static let initialScrollViewOffsetY: CGFloat = 450.0
    private var isZoomingBlocked = false
    private var isFirstAppearance = true

    lazy var collectionsDataSource = RxCollectionViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, FantasyDetailsViewModel.CellModel>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in
            let cell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                     for: indexPath)!

            cell.fantasiesCount = model.cardsCount
            cell.imageURL = model.imageURL
            cell.title = model.title
            cell.isPaid = model.isPaid

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

        viewModel.collectionsDataSource
            .drive(collectionView.rx.items(dataSource: collectionsDataSource))
            .disposed(by: rx.disposeBag)

        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)

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
        scrollView.contentInsetAdjustmentBehavior = .never

        gradientBackgroundView.isHidden = true
        gradientBackgroundView.addFantasyGradient()
        view.backgroundColor = .clear
        backgroundView.backgroundColor = .fantasyCardBackground
        backgroundView.isHidden = true
        closeButton.alpha = 0.0
        optionButton.alpha = 0.0
        titleLabel.alpha = 0.0

        backgroundImageWidth.constant = FantasyDetailsViewController.minBackgroundImageWidth
        backgroundImageHeight.constant = FantasyDetailsViewController.minBackgroundImageHeight
        backgroundImageView.contentMode = .scaleAspectFill

        stackView.backgroundColor = .fantasyLightGrey

        [descriptionView,
         preferenceView,
         collectionsView,
         backgroundImageView].forEach { $0?.layer.cornerRadius = 16.0 }

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
        if scrollView.contentOffset.y == 0 {
            animateContentOffsetChange(contentOffset:
                CGPoint(x: 0, y: FantasyDetailsViewController.initialScrollViewOffsetY))
        } else {
            isZoomingBlocked = true
            animateDisappearance()
        }
    }

    @IBAction func zoomCard(_ sender: Any) {
        animateContentOffsetChange(contentOffset: .zero)
    }

    @IBAction func expandOrCollapseStory(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        collapsedDescriptionHeight.isActive = !sender.isSelected
    }
}

// MARK: - Scrolling
extension FantasyDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isZoomingBlocked else { return }

        configureNavigationBarButtons()
        configureBackground()

        let expectedHeight = UIScreen.main.bounds.height * (scrollView.frame.height - scrollView.contentOffset.y) /
            scrollView.frame.height
        let expectedWidth = expectedHeight * FantasyDetailsViewController.minBackgroundImageWidth /
            FantasyDetailsViewController.minBackgroundImageHeight
        animateCardScale(toSize: CGSize(width: expectedWidth, height: expectedHeight))
    }

    private func configureNavigationBarButtons() {
        if scrollView.contentOffset.y == 0 {
            closeButton.setImage(R.image.cardDetailsClose(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        } else if scrollView.contentOffset.y >= scrollView.frame.height - navigationBar.frame.maxY {
            closeButton.setImage(R.image.navigationBackButton(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOptionPlain(), for: .normal)
        } else {
            closeButton.setImage(R.image.cardDetailsBack(), for: .normal)
            optionButton.setImage(R.image.cardDetailsOption(), for: .normal)
        }
    }

    private func configureBackground() {
        if scrollView.contentOffset.y >= scrollView.frame.height - navigationBar.frame.maxY    {
            gradientBackgroundView.isHidden = false
        } else {
            gradientBackgroundView.isHidden = true
        }
    }
}
