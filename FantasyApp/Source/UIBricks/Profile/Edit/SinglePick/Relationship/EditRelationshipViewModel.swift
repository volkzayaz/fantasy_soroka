//
//  EditRelationshipViewModel.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 13.11.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class EditRelationshipViewModel: MVVM_ViewModel {
    
    let router: EditRelationshipRouter
    
    enum Row: IdentifiableType, Equatable {
        case relationshipType(RelationshipType, isSelected: Bool)
        case partnerGender(Gender, isSelected: Bool, isEnabled: Bool)
        
        var identity: String {
            switch self {
            case .relationshipType(let relationshipType, _):
                return "relationshipType \(relationshipType)"
            case .partnerGender(let gender, _, _):
                return "partnerGender \(gender)"
            }
        }
    }
    
    init(router: EditRelationshipRouter, currentStatus: RelationshipStatus?, callback: ((RelationshipStatus) -> Void)?) {
        self.router = router
        relationshipType = BehaviorRelay(value: currentStatus?.relationshipType)
        partnerGender = BehaviorRelay(value: currentStatus?.partnerGender)
        self.callback = callback
    }
    
    var tableData: Driver<[AnimatableSectionModel<String, Row>]> {
        Observable.combineLatest(relationshipType, partnerGender).map { (relationshipType, partnerGender) in
            [
                AnimatableSectionModel(model: "relationshipType", items: RelationshipType.allCases.map { Row.relationshipType($0, isSelected: $0 == relationshipType) }),
                AnimatableSectionModel(model: "partnerGender", items: Gender.allCases.map { Row.partnerGender($0, isSelected: $0 == partnerGender, isEnabled: relationshipType != .single) })
            ]
        }.asDriver(onErrorJustReturn: [])
    }
    
    var isPartnerGenderEnabled: Driver<Bool> {
        relationshipType.map { $0 != .single }.asDriver(onErrorJustReturn: false)
    }
    
    var partnerGenderError: Driver<Bool> {
        partnerGenderErrorRelay.asDriver()
    }
    
    func selectRelationshipType(index: Int) {
        relationshipType.accept(RelationshipType.allCases[index])
        partnerGenderErrorRelay.accept(false)
    }
    
    func selectPartnerGender(index: Int) {
        partnerGender.accept(Gender.allCases[index])
        partnerGenderErrorRelay.accept(false)
    }
    
    func back() {
        if let relationshipType = relationshipType.value, (relationshipType == .single || partnerGender.value != nil) {
            callback?(RelationshipStatus(relationshipType: relationshipType, partnerGender: partnerGender.value))
            router.popBack()
        } else if relationshipType.value == nil {
            router.popBack()
        } else {
            partnerGenderErrorRelay.accept(true)
        }
    }
    
    // MARK: - Private
    
    private let relationshipType: BehaviorRelay<RelationshipType?>
    private let partnerGender: BehaviorRelay<Gender?>
    private let callback: ((RelationshipStatus) -> Void)?
    private let partnerGenderErrorRelay = BehaviorRelay<Bool>(value: false)
}
