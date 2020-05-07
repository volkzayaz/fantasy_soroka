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
import RxDataSources

class FantasyCollectionDetailsViewController: UIViewController, MVVM_View {
    
    var viewModel: FantasyCollectionDetailsViewModel!
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, VM.Model>>(
        configureCell: { [unowned self] (_, tableView, ip, x) in
            
            let viewModel = self.viewModel!
            
            switch x {
                
            case .top:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.topCollectionPurchaseCell,
                                                                         for: ip)!
                
                ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
                    .drive(cell.cardImageView.rx.image)
                    .disposed(by: cell.rx.disposeBag)
                
                cell.nameLabel.text = viewModel.collection.title
                cell.viewModel = viewModel
                
                return cell
                
            case .expandable(let title, let description):
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.fantasyCollectionDetailsCell,
                for: ip)!
                
                
                cell.detailsLabel.setHTMLFromString(htmlText: description)
                
                cell.sectionTitleLabel.text = title
                cell.tableView = tableView
                
                cell.perform(change: viewModel.expanded[title] ?? false, animated: false)
                
                cell.change = { [weak self] x in
                    self?.viewModel.expanded[title] = x
                }
                
                return cell
                
            case .whatsInside:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.whatsInsideCollectionDetailsCell,
                                                         for: ip)!
                
                cell.cardsCountLabel.text = "\(viewModel.collection.cardsCount) \(viewModel.collection.itemsNamePlural)"
                cell.viewModel = viewModel
                
                return cell
                
            case .author:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.authorCollectionCell, for: ip)!
                
                cell.viewModel = viewModel
                
                return cell
                
            case .bottom:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bottomCollectionPurchaseCell,
                                                         for: ip)!
                
                ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
                    .drive(cell.cardImageView.rx.image)
                    .disposed(by: cell.rx.disposeBag)
                
                cell.nameLabel.text = viewModel.collection.title
                cell.viewModel = viewModel
                
                return cell
                
            case .share:
                           
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareCollectionCell,
                                                         for: ip)!
                
                cell.viewModel = viewModel
                
                return cell
                           
            }
            
        })
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollableBackgroundView: UIView! {
        didSet {
            scrollableBackgroundView.clipsToBounds = true
            scrollableBackgroundView.layer.cornerRadius = 20
            scrollableBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var collTableView: CoolTable!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let tableHeaderView: UIView = {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
        return headerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        
        viewModel.dataSource
            .drive(collTableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
            .drive(imageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        collTableView.rx.contentOffset
            .subscribe(onNext: { [unowned self] offset in
                
                let imageStretchHeight = abs(offset.y) - (self.imageContainer.frame.height - self.tableHeaderView.frame.height)
                
                if imageStretchHeight > self.view.frame.height * 0.13 && offset.y.isLess(than: 0)  {
                    self.dismiss(animated: true, completion: nil)
                    return
                }

                if imageStretchHeight >= 0 && offset.y.isLess(than: 0) {
                    self.imageHeightConstraint.constant = imageStretchHeight
                } else {
                    self.imageHeightConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
                                
                self.scrollableBackgroundView.frame = .init(origin: CGPoint(x: offset.x, y: -1 * (offset.y - self.tableHeaderView.frame.height)),
                                                            size: CGSize(width: self.view.frame.size.width,
                                                                         height: max(self.view.frame.size.height,
                                                                                     self.collTableView.contentSize.height)))
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.reloadTrigger
            .delay(2, scheduler: MainScheduler.instance)
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
        
        collTableView.tableHeaderView = tableHeaderView
        
        let top = (imageView.frame.size.height - tableHeaderView.frame.height) - scrollableBackgroundView.layer.cornerRadius
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
            collapseButton?.backgroundColor = .fantasyLightGrey
            collapseButton?.setTitleColor(.fantasyPink, for: .normal)
            collapseButton?.titleLabel?.font = .boldFont(ofSize: 14)
            collapseButton?.layer.cornerRadius = collapseButton.frame.height / 2.0
        }
    }
    
    @IBAction func collapseAction(_ sender: UIButton) {
        let shouldCollapse = detailsLabel.isTruncated
        perform(change: shouldCollapse, animated: true)
    }
    
    func perform(change: Bool, animated: Bool) {
     
        self.change?(change)
        
        detailsLabel.numberOfLines = change ? 0 : 2
        
        collapseButton.setTitle(change ? "Show Less" : "Read More", for: .normal)
        
        if animated {
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }
        
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
            
            if author?.srcFb?.count ?? 0 == 0 {
                fbButton.removeFromSuperview()
            }
            
            if author?.srcInstagram?.count ?? 0 == 0 {
                instaButton.removeFromSuperview()
            }
            
            if author?.srcWeb?.count ?? 0 == 0 {
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



extension UILabel {
    func setHTMLFromString(htmlText: String) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'SFProText'; font-size: \(self.font!.pointSize); color: #484e5e \">%@</span>", htmlText)

        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}
