//
//  Fantasy.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources

enum Fantasy {}
extension Fantasy {
    
    struct Card: Equatable, IdentifiableType, Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case text
            case story
            case imageURL = "src"
            case isPaid
            case likes
            case dislikes
            case blocks
            case category = "coverRubric"
            case collectionName
            case art
            
        }
        
        let id: String
        let text: String
        let story: String
        let imageURL: String
        let isPaid: Bool
        let likes: Int
        let dislikes: Int
        let blocks: Int
        let category: String
        let collectionName: String
        let art: String
        
        
        ///surrogate property
        ///whether this card belongs to free collection or payed collection
        var isFree: Bool {
            return !isPaid
        }
        
        var identity: String {
            return id
        }
        
        enum Reaction: Int, Codable {
               case like, dislike, block, neutral
        };
    }
    
    struct Collection: Equatable, IdentifiableType, Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case details
            case whatsInside
            case imageURL = "src"
            case cardsCount = "size"
            case isPaid
            case isIAPPurchased = "isIAPPurhcased"
            case productId
            
            case loveThis
            case highlights
            
            case category = "coverRubric"
            case itemsNamePlural = "coverItems"
            case hint = "hintText"
            case author
            case customBlock
        }
        
        let id: String
        let title: String
        
        let whatsInside: String
        let imageURL: String
        let cardsCount: Int
        
        let isPaid: Bool /// free if false.
        let productId: String? ///
        
        var isIAPPurchased: Bool
        
        var isAvailable: Bool {
            
            if isPaid == false {
                return true
            }
            
            if isIAPPurchased || appStateSlice.currentUser!.fantasies.purchasedCollections.contains(where: { $0.id == id }) {
                return true
            }
            
            if let u = User.current, u.subscription.isSubscribed {
                return true
            }
            
            return false
            
        }
        
        let details: String
        let loveThis: String
        let highlights: String
        
        let category: String
        let itemsNamePlural: String
        let hint: String
        
        let author: Author?
        let customBlock: CustomBlock?
        
        var identity: String {
            return id
        }
        
        struct Author: Codable, Equatable {
          
            let title: String
            let subTitle: String
            let about: String
            
            let srcWeb: String?
            let srcInstagram: String?
            let srcFb: String?
            
            let imageSrc: String?
            
        }
        
        struct CustomBlock: Codable, Equatable {
            
            let title: String
            let description: String
            
        }
    }
    
}

struct ProtectedEntity<T: IdentifiableType & Equatable>: IdentifiableType, Equatable {
    let entity: T
    let isProtected: Bool

    var identity: T.Identity {
        return entity.identity
    }
    
}

extension AppState.FantasiesDeck {

    /*
        returns - Bool.
            False - state should be refreshed from server
            True  - state is consistent with server
     */
    @discardableResult
    mutating func pop(card: Fantasy.Card) -> Bool {
        
        guard var x = cards else {
            return true
        }
        
        guard x.count > 0 else {
            return true
        }
        
        guard let maybeIndex = x.firstIndex(of: card) else {
            return false
        }
        
        x.remove(at: maybeIndex)
        
        cards = x
        
        return true
        
    }
    
}

import Branch
extension Fantasy.Card {
    
    func share(presenter: UIViewController) -> BranchUniversalObject {
        
        let buo = BranchUniversalObject(canonicalIdentifier: "card/\(id)/\(User.current!.id)")
        buo.title = "Fantasy"
        buo.contentDescription = R.string.localizable.branchObjectCardShareDescription()
        buo.publiclyIndex = true
        buo.imageUrl = immutableNonPersistentState.shareCardImageURL
        buo.getShortUrl(with: BranchLinkProperties()) { [weak b = buo, weak v = presenter] (url, error) in
            
            b?.showShareSheet(with: BranchLinkProperties(),
                                andShareText: R.string.localizable.branchObjectCardShareDescription(),
                                from: v) { (activityType, completed) in

            }
            
        }
        
        return buo
    }
    
//    static var fakes: [Fantasy.Card] {
//
//        return [.init(name: "BJ", description: "Some vanila stuff", isPaid: false),
//                .init(name: "Go down", description: "Even more vanila stuff", isPaid: false),
//                .init(name: "anal", description: "Doing kinky dirty stuff", isPaid: false),
//                .init(name: "BDSM", description: "For those who love it rough", isPaid: false),
//                .init(name: "ESPN", description: "Watch your team getting fucked every weekend online. Real hardcore shit", isPaid: false)]
//
//    }
    
}

extension Fantasy.Collection {
    
    func share(presenter: UIViewController) -> BranchUniversalObject {
        
        let buo = BranchUniversalObject(canonicalIdentifier: "collection/\(id)")
        buo.title = "Fantasy"
        buo.contentDescription = R.string.localizable.branchObjectCollectionShareDescription()
        buo.publiclyIndex = true
        buo.imageUrl = immutableNonPersistentState.shareCollectionImageURL
        buo.getShortUrl(with: BranchLinkProperties()) { [weak b = buo, weak v = presenter] (url, error) in
            
            b?.showShareSheet(with: BranchLinkProperties(),
                                andShareText: R.string.localizable.branchObjectCollectionShareDescription(),
                                from: v) { (activityType, completed) in

            }
            
        }
        
        return buo
    }
    
    static var fake: Fantasy.Collection {
        
        return Fantasy.Collection(id: "", title: "", whatsInside: "", imageURL: "", cardsCount: 0, isPaid: true, productId: "", isIAPPurchased: false, details: "", loveThis: "", highlights: "", category: "", itemsNamePlural: "", hint: "", author: nil, customBlock: nil)
        
    }
    
}
