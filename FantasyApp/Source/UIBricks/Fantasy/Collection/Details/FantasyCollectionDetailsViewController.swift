//
//  FantasyCollectionDetailsViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/30/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class FantasyCollectionDetailsViewController: UIViewController, MVVM_View, UITableViewDataSource {
    
    var viewModel: FantasyCollectionDetailsViewModel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollableBackgroundView: UIView! {
        didSet {
            scrollableBackgroundView.clipsToBounds = true
            scrollableBackgroundView.layer.cornerRadius = 20
            scrollableBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var collTableView: CoolTable!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        
        ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
            .drive(imageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        collTableView.rx.contentOffset
        .map { offset in
            return CGPoint(x: offset.x, y: -1 * (offset.y))
        }
        .subscribe(onNext: { [unowned self] (x) in
            
            self.scrollableBackgroundView.frame = .init(origin: x,
                                                        size: CGSize(width: self.view.frame.size.width,
                                                                     height: max(self.view.frame.size.height,
                                                                                 self.collTableView.contentSize.height)))
        })
            .disposed(by: rx.disposeBag)
        
        viewModel.reloadTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.collTableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    override var prefersNavigationBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let top = (imageView.frame.size.height) - scrollableBackgroundView.layer.cornerRadius
        
        collTableView.contentInset = .init(top: top,
                                           left: 0, bottom: 0, right: 0)
        collTableView.setContentOffset(.init(x: 0, y: -top), animated: true)
        
        viewModel.viewAppeared()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.viewWillDisappear()
    }
    
    @IBAction func popBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var x = 7
        
        if viewModel.collection.author != nil {
            x+=1
        }
        
        return x
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.topCollectionPurchaseCell,
                                                     for: indexPath)!
            
            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
                .drive(cell.cardImageView.rx.image)
                .disposed(by: cell.rx.disposeBag)
            
            cell.nameLabel.text = viewModel.collection.title
            cell.viewModel = viewModel
            
            return cell
        }
        else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.fantasyCollectionDetailsCell,
            for: indexPath)!
            
            cell.detailsLabel.text = viewModel.collection.details
            cell.sectionTitleLabel.text = "Details"
            cell.tableView = tableView
            
            cell.perform(change: viewModel.deatilsCollapsed)
            
            cell.change = { [weak self] x in
                self?.viewModel.deatilsCollapsed = x
            }
            
            return cell
            
        }
        else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.whatsInsideCollectionDetailsCell,
                                                     for: indexPath)!
            
            cell.cardsCountLabel.text = "\(viewModel.collection.cardsCount) \(viewModel.collection.itemsNamePlural)"
            cell.viewModel = viewModel
            
            return cell
            
        }
        else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.fantasyCollectionDetailsCell,
                                                     for: indexPath)!
            
            cell.detailsLabel.text = viewModel.collection.highlights
            cell.sectionTitleLabel.text = "Highlights"
            cell.tableView = tableView
            
            cell.perform(change: viewModel.highlightsCollapsed)
            
            cell.change = { [weak self] x in
                self?.viewModel.highlightsCollapsed = x
            }
            
            return cell
            
        }
        else if indexPath.section == 4 {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.fantasyCollectionDetailsCell,
                                                     for: indexPath)!
            
            cell.detailsLabel.text = viewModel.collection.loveThis
            cell.sectionTitleLabel.text = "You'll Love This Collection If"
            cell.tableView = tableView
            
            cell.perform(change: viewModel.loveThisCollapsed)
            
            cell.change = { [weak self] x in
                self?.viewModel.loveThisCollapsed = x
            }
            
            return cell
                
        }
        else if let _ = viewModel.collection.author, indexPath.section == 5 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.authorCollectionCell, for: indexPath)!
            
            cell.viewModel = viewModel
            
            return cell
        }
        else if indexPath.section == 5 || (indexPath.section == 6 && viewModel.collection.author != nil) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bottomCollectionPurchaseCell,
            for: indexPath)!
            
            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
                .drive(cell.cardImageView.rx.image)
                .disposed(by: cell.rx.disposeBag)
            
            cell.nameLabel.text = viewModel.collection.title
            cell.viewModel = viewModel
            
            return cell
            
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareCollectionCell,
            for: indexPath)!
            
            cell.viewModel = viewModel
            
            return cell
            
        }
        
        
    }
    
} 

///TableViews

class TopCollectionPurchaseCell: UITableViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionCategoryLabel: UILabel!
    @IBOutlet weak var buyButton: PrimaryButton! {
        didSet {
            buyButton.mode = .selector
            buyButton.titleFont = .mediumFont(ofSize: 14)
            buyButton.addFantasyGradient()
            buyButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintView: UIView!
    
    var viewModel: FantasyCollectionDetailsViewModel! {
        didSet {
            if viewModel.collectionPurchased {
                buyButton.setTitle("Open", for: .normal)
            }
            else {
                viewModel.price
                    .drive(buyButton.rx.title(for: .normal))
                    .disposed(by: rx.disposeBag)
            }
            
            collectionCategoryLabel.text = viewModel.collection.category
            hintLabel.text = viewModel.collection.hint
            if viewModel.collection.hint.count == 0 {
                hintView.isHidden = true
            }
        }
    }
    
    @IBAction func buy() {
        viewModel.buy()
    }
    
}

class FantasyCollectionDetailsCell: UITableViewCell {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!{
        didSet {
            detailsLabel.numberOfLines = 2
            detailsLabel.contentMode = .top
        }
    }
    weak var tableView: UITableView?
    var change: ( (Bool) -> Void )?
    
    @IBOutlet weak var collapseButton: UIButton! {
        didSet {
            collapseButton.backgroundColor = .fantasyLightGrey
            collapseButton.setTitleColor(.fantasyPink, for: .normal)
            collapseButton.titleLabel?.font = .boldFont(ofSize: 14)
            collapseButton.layer.cornerRadius = collapseButton.frame.height / 2.0
        }
    }
    
    @IBAction func collapseAction(_ sender: UIButton) {
        let shouldCollapse = detailsLabel.isTruncated
        perform(change: shouldCollapse)
    }
    
    func perform(change: Bool) {
     
        self.change?(change)
        
        detailsLabel.numberOfLines = change ? 0 : 2
        
        collapseButton.setTitle(change ? "Show Less" : "Read More", for: .normal)
        
        tableView?.beginUpdates()
        tableView?.endUpdates()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        change = nil
    }
    
}

class WhatsInsideCollectionDetailsCell: UITableViewCell {
    
    @IBOutlet weak var cardsCountLabel: UILabel!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
 
    var viewModel: FantasyCollectionDetailsViewModel! {
        didSet {
            viewModel.availableCards
                .map { $0.map { $0.imageURL } }
                .map { urls -> [String] in
                    
                    if urls.count == 1 {
                        return [urls.first!, "stub", "stub", "stub", "andMore"]
                    }
                    
                    return urls
            }
            .drive(cardsCollectionView.rx.items(cellIdentifier: "CardCollectionCell",
                                                cellType: CardCollectionCell.self)) { index, model, cell in
                                                    
                                                    cell.cardImageView.isHidden = model == "andMore"
                                                    
                                                    if model == "stub" {
                                                        cell.cardImageView.image = R.image.collectionStubBlured()!
                                                        return
                                                    }
                                                    
                                                    if model == "andMore" {
                                                        return
                                                    }
                                                    
                                                    ImageRetreiver.imageForURLWithoutProgress(url: model)
                                                        .drive(cell.cardImageView.rx.image)
                                                        .disposed(by: cell.rx.disposeBag)
                                                    
            }
            .disposed(by: bag)
        }
    }
    
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.bag = DisposeBag()
    }
    
}

class BottomCollectionPurchaseCell: UITableViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionCategoryLabel: UILabel!
    @IBOutlet var buyButton: PrimaryButton! {
        didSet {
            buyButton.mode = .selector
            buyButton.titleFont = .boldFont(ofSize: 16)
            buyButton.addFantasyGradient()
            buyButton.setTitle("", for: .normal)
        }
    }
    
    var viewModel: FantasyCollectionDetailsViewModel!{
        didSet {
            
            collectionCategoryLabel.text = viewModel.collection.category
            
            if viewModel.collectionPurchased {
                buyButton.setTitle("Open", for: .normal)
            }
            else {
                viewModel.price
                    .map { $0 == "Get" ? "Get" : "Buy for \($0)" }
                    .drive(buyButton.rx.title(for: .normal))
                    .disposed(by: rx.disposeBag)
            }
            
        }
    }
    
    @IBAction func buy() {
        viewModel.buy()
    }
    
}

class ShareCollectionCell: UITableViewCell {
    
    var viewModel: FantasyCollectionDetailsViewModel!
    
    @IBOutlet weak var shareButton: PrimaryButton! {
        didSet {
            shareButton.useTransparency = false
            shareButton.normalBackgroundColor = UIColor(fromHex: 0xEDEDF1)
            shareButton.setupBackgroundColor()
            shareButton.setTitleColor(UIColor.fantasyPink, for: .normal)
        }
    }
    
    @IBAction func shareButton(_ sender: Any) {
        viewModel.share()
    }
    
}

class AuthorCollectionCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet var fbButton: UIButton!
    @IBOutlet var instaButton: UIButton!
    @IBOutlet var webButton: UIButton!
    
    var viewModel: FantasyCollectionDetailsViewModel!{
        didSet {
            
            let author = viewModel.collection.author
            
            nameLabel.text = viewModel.collection.author?.title
            statusLabel.text = viewModel.collection.author?.subTitle
            descriptionLabel.text = viewModel.collection.author?.about
            
            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.author?.imageSrc ?? "")
                .map { $0 ?? R.image.noPhoto() }
                .drive(photoImageView.rx.image)
                .disposed(by: rx.disposeBag)
            
            if author?.srcFb == nil {
                fbButton.removeFromSuperview()
            }
            
            if author?.srcInstagram == nil {
                instaButton.removeFromSuperview()
            }
            
            if author?.srcWeb == nil {
                webButton.removeFromSuperview()
            }
            
        }
    }
    
    @IBAction func facebook(_ sender: Any) {
        viewModel.openAuthorFB()
    }
    
    @IBAction func instagram(_ sender: Any) {
        viewModel.openAuthorInsta()
    }
    
    @IBAction func website(_ sender: Any) {
        viewModel.openAuthorWeb()
    }
    
}



class CardCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var andMoreLable: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
     
        cardImageView.isHidden = false
        cardImageView.image = nil
        
    }
    
}

