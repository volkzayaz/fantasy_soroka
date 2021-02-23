//
//  UserProfileFantasiesCell.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 22.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class UserProfileFantasiesCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var sectionsTableDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, UserProfileViewModel.Row.Fantasies>>(configureCell: { [unowned self] (_, cv, ip, model) in
        
        switch model {
            
        case .card(let card):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyListCell,
                                              for: ip)!
            
            cell.set(protectedCard: ProtectedEntity(entity: card, isProtected: true))
            
            return cell
            
        case .sneakPeek(let sneakPeek):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.fantasyCollectionCollectionViewCell,
                                              for: ip)!
            
            let i = [R.image.collectionStubBlured()!,
                R.image.gay()!,
                R.image.transsexual()!,
                R.image.pansexual()!
            ].randomElement()!
            
            cell.imageView.regularImageView.image = i
           // cell.isPurchased = false //sneakPeek.isPaid
            
            //cell.fantasiesCountLabel.text = "\(sneakPeek.amountlikedCardsByUser) \(sneakPeek.coverItems)"
            cell.paidLabel.text = sneakPeek.coverRubric
            cell.dotsImageView.isHidden = true
            cell.deleteDeckButton.isHidden = true
            
            return cell
            
        }
        
    })
    
    private let bottleneck: BehaviorSubject<[UserProfileViewModel.Row.Fantasies]> = .init(value: [])
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(R.nib.fantasyCollectionCollectionViewCell)
        collectionView.register(R.nib.fantasyListCell)
        
        bottleneck.map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: sectionsTableDataSource))
            .disposed(by: bag)
    }
    
    func bindModel(x: [UserProfileViewModel.Row.Fantasies]) {
        bottleneck.onNext(x)
    }
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
