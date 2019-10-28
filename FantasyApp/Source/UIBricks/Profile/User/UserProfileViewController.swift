//
//  UserProfileViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class UserProfileViewController: UIViewController, MVVM_View {
    
    var viewModel: UserProfileViewModel!
    
    lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, UserProfileViewModel.Photo>>(configureCell: { [unowned self] (_, cv, ip, x) in
        
        switch x {
            
        case .privateStub(let x):
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePhotoStubCell, for: ip)!
            
            cell.amountLabel.text = "\(x) Secret Photos"
            
            return cell
            
        default:
        
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePhotoCell, for: ip)!
            
            cell.set(photo: x)
            
            return cell
            
        }
        
    })
    
    lazy var sectionsTableDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, UserProfileViewModel.Row>>(configureCell: { [unowned self] (_, tv, ip, section) in
        
        switch section {
        case .basic(let text, let isMember):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileBasicCell, for: ip)!
            
            cell.basicLabel.text = text
            cell.goldMemberBadge.removeFromSuperview()
            if isMember {
                cell.stackView.addArrangedSubview(cell.goldMemberBadge)
            }
            
            self.viewModel.likedStikerHidden
                .drive(cell.likeIndicatorImageView.rx.isHidden)
                .disposed(by: cell.rx.disposeBag)
            
            return cell
            
        case .about(let about, let sexuality):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileAboutCell, for: ip)!
            
            cell.descriptionLabel.text = about
            cell.sexualityGradientView.sexuality = sexuality
            
            return cell
            
        case .bio(let image, let text):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileBioCell, for: ip)!
            
            cell.indicatorImageView.image = image
            cell.descriptionTextLabel.text = text
            
            return cell
            
        case .fantasy(let x):
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileFantasyCell, for: ip)!
            
            cell.textLabel?.text = x
            
            return cell
            
        case .answer(let q, let a):

            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userProfileAnswerCell, for: ip)!
            
            cell.questionLabel.text = q
            cell.answerLabel.text = a
            
            return cell
            
        }
        
    })
    
    @IBOutlet weak var indicatorStackView: UIStackView! {
        didSet {
            indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    @IBOutlet weak var actionButtonsStackView: UIStackView! {
        didSet {
            actionButtonsStackView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var scrollableBackground: UIView! {
        didSet {
            scrollableBackground.clipsToBounds = true
            scrollableBackground.layer.cornerRadius = 42
            scrollableBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var actionContainer: UIView! {
        didSet {
            
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.colors = [UIColor.clear.cgColor,
                                    UIColor(white: 0, alpha: 0.102).cgColor]
            
            actionContainer.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private var avaliableSheetActions: [(String, () -> Void)] = [] {
        didSet {
            optionsButton.isHidden = avaliableSheetActions.count == 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.rx.contentOffset
            .map { [unowned self] offset in
                return CGPoint(x: offset.x, y: -1 * (offset.y - self.view.safeAreaInsets.top))
            }
            .subscribe(onNext: { [unowned self] (x) in
                
                self.scrollableBackground.frame = .init(origin: x,
                                                        size: self.profileTableView.contentSize)
            })
            .disposed(by: rx.disposeBag)
        
        let layout = photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = photosCollectionView.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        //MARK: ViewModel binding
        
        viewModel.photos
            .do(onNext: { [weak self] (data) in
                
                self?.indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
                
                for i in data.first!.items.enumerated() {
                    let x = UIView()
                    x.backgroundColor = i.offset == 0 ? .white : UIColor(white: 1, alpha: 0.3)
                    x.layer.cornerRadius = 1.5
                    self?.indicatorStackView.addArrangedSubview(x)
                }

            })
            .drive(photosCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.sections
            .map { $0.map { AnimatableSectionModel(model: $0.0, items: $0.1) } }
            .drive(profileTableView.rx.items(dataSource: sectionsTableDataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.relationActions
            .drive(onNext: { [weak self] (data) in
                
                self?.actionButtonsStackView.subviews.forEach { $0.removeFromSuperview() }
                var sheetActions: [(String, () -> Void)] = []
                data.forEach { (action) in
                    
                    switch action.descriptior {
                    case .openRoomButton:
                        let b = SecondaryButton()
                        b.setTitle("Open Room", for: .normal)
                        b.rx.controlEvent(.touchUpInside)
                            .subscribe(onNext: action.action)
                            .disposed(by: b.rx.disposeBag)
                        self?.actionButtonsStackView.addArrangedSubview(b)
                        
                        b.snp.makeConstraints { $0.size.equalTo(CGSize(width: 254, height: 52)) }
                        
                    case .imageButton(let image):
                        let button = UIButton(type: .custom)
                        button.setImage(image, for: .normal)
                        button.rx.controlEvent(.touchUpInside)
                            .subscribe(onNext: action.action)
                            .disposed(by: button.rx.disposeBag)
                        self?.actionButtonsStackView.addArrangedSubview(button)
                        
                    case .actionSheetOption(let description):
                        sheetActions.append( (description, action.action) )
                        
                    }
                    
                }
                
                self?.avaliableSheetActions = sheetActions
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override var prefersNavigationBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let top = photosCollectionView.frame.size.height - scrollableBackground.layer.cornerRadius
        let bottom = actionContainer.bounds.size.height
        
        profileTableView.contentInset = .init(top: top,
                                              left: 0, bottom: bottom, right: 0)
        profileTableView.setContentOffset(.init(x: 0, y: -top), animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        actionContainer.layer.sublayers!.first!.frame = actionContainer.bounds
    }
    
    @IBAction func showOptions() {
        
        let actions: [UIAlertAction] = avaliableSheetActions.map { (name, action) in
            UIAlertAction(title: name, style: .default, handler: { _ in action() })
            } + [UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
        
        self.showDialog(title: "", text: "Pick an action",
                        style: .actionSheet,
                        actions: actions)
        
    }
    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = photosCollectionView.indexPathsForVisibleItems.first?.row else {
            return
        }
        
        indicatorStackView.subviews.enumerated().forEach {
            $0.element.backgroundColor = $0.offset == index ? .white : UIColor(white: 1, alpha: 0.3)
        }
    }
    
}


class CoolTable: UITableView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return point.y > 0
    }
    
}
