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
    
    lazy var deckDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CellModel>>(configureCell: { [unowned self] (_, cv, ip, model) in
        
        switch model {
    
        case .deck(let collection):
          let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                            for: ip)!
            cell.model = collection
            cell.set(imageURL: collection.imageURL)
            cell.title = collection.title
            cell.isPurchased = collection.isPurchased
            cell.dotsImageView.isHidden = true
            
            return cell
        
        }
    })
    
    private let bottleneck: BehaviorSubject<[CellModel]> = .init(value: [])
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)
        
        bottleneck
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: deckDataSource))
            .disposed(by: rx.disposeBag)
    }
    
    func bindModel(x: [CellModel]) {
        bottleneck.onNext(x)
    }
   
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    enum CellModel {
        case deck(Fantasy.Collection)
    }
    
}
