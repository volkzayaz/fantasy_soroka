//
//  CategoryFantasiesTableViewCell.swift
//  FantasyApp
//
//  Created by Максим Сорока on 08.02.2021.
//  Copyright © 2021 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources


class CategoryFantasiesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var numberDecks: UILabel!
    @IBOutlet weak var decksCountLabel: UILabel!
    
    lazy var deckDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Fantasy.Collection>>(configureCell: { [unowned self] (_, cv, ip, collection) in
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                          for: ip)!
        
        switch collection.monetizationType {
        case .free:
            cell.deckStateImageView.image = UIImage()
        case .nonConsumable(_):
            cell.deckStateImageView.image = UIImage()
        case .subscription:
            cell.deckStateImageView.image = R.image.parrot()
        }
        
        if collection.isPurchased {
            cell.deckStateImageView.image = R.image.isPurchased()
        }
        
        cell.model = collection
        cell.set(imageURL: collection.imageURL)
        cell.title = collection.title
        cell.dotsImageView.isHidden = true
        
        return cell
        
        
    })
    
    private let bottleneck: BehaviorSubject<[Fantasy.Collection]> = .init(value: [])
    var fantasyDeckViewModel: FantasyDeckViewModel? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)
        
        collectionView.rx.modelSelected(Fantasy.Collection.self)
            .subscribe(onNext: { [unowned self] collection in
                fantasyDeckViewModel?.show(collection: collection)
            })
            .disposed(by: rx.disposeBag)
        
        
        bottleneck
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: deckDataSource))
            .disposed(by: rx.disposeBag)
    }
    
    func bindModel(x: [Fantasy.Collection]) {
        bottleneck.onNext(x)
    }
}
