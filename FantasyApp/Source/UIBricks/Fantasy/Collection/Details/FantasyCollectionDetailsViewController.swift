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
        
    }
    
    @IBAction func popBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
            
            return cell
            
        }
        else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.whatsInsideCollectionDetailsCell,
            for: indexPath)!
            
            cell.cardsCountLabel.text = "\(viewModel.collection.cardsCount) cards"
            cell.descriptionLabel.text = viewModel.collection.whatsInside
            
            viewModel.firstCard
                .drive(onNext: { (x) in
                    
                    cell.set(card: x)
                    
                })
                .disposed(by: rx.disposeBag)
            
            return cell
            
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bottomCollectionPurchaseCell,
            for: indexPath)!
            
            ImageRetreiver.imageForURLWithoutProgress(url: viewModel.collection.imageURL)
                .drive(cell.cardImageView.rx.image)
                .disposed(by: cell.rx.disposeBag)
            
            cell.nameLabel.text = viewModel.collection.title
            cell.viewModel = viewModel
            
            return cell
            
        }
        
        
    }
    
} 

///TableViews

class TopCollectionPurchaseCell: UITableViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyButton: PrimaryButton! {
        didSet {
            buyButton.mode = .selector
            buyButton.titleFont = .mediumFont(ofSize: 14)
            buyButton.addFantasyGradient()
            buyButton.setTitle("", for: .normal)
        }
    }
    
    var viewModel: FantasyCollectionDetailsViewModel! {
        didSet {
            viewModel.price
                .drive(buyButton.rx.title(for: .normal))
                .disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func buy() {
        viewModel.buy()
    }
    
}

class FantasyCollectionDetailsCell: UITableViewCell {
    
    @IBOutlet weak var detailsLabel: UILabel!
    
}

class WhatsInsideCollectionDetailsCell: UITableViewCell {
    
    @IBOutlet weak var cardsCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
 
    func set(card: Fantasy.Card) {
     
        Observable<[String]>
            .just([card.imageURL, "stub", "stub", "stub", "andMore"])
            .bind(to: cardsCollectionView.rx.items(cellIdentifier: "CardCollectionCell",
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
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.bag = DisposeBag()
    }
    
}

class BottomCollectionPurchaseCell: UITableViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyButton: PrimaryButton! {
        didSet {
            buyButton.mode = .selector
            buyButton.titleFont = .boldFont(ofSize: 16)
            buyButton.addFantasyGradient()
            buyButton.setTitle("", for: .normal)
        }
    }
    
    var viewModel: FantasyCollectionDetailsViewModel!{
        didSet {
            viewModel.price
                .map { "Buy for \($0)" }
                .drive(buyButton.rx.title(for: .normal))
                .disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func buy() {
        viewModel.buy()
    }
    
}

class CardCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var andMoreLable: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
}
