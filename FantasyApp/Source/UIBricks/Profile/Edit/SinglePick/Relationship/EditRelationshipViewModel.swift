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
        case partnerGender(Gender, isSelected: Bool)
        
        var identity: String {
            switch self {
            case .relationshipType(let relationshipType, _):
                return "relationshipType \(relationshipType)"
            case .partnerGender(let gender, _):
                return "partnerGender \(gender)"
            }
        }
    }
    
    init(router: EditRelationshipRouter, currentStatus: RelationshipStatus, callback: ((RelationshipStatus) -> Void)?) {
        self.router = router
        relationshipType = BehaviorRelay(value: currentStatus.relationshipType)
        partnerGender = BehaviorRelay(value: currentStatus.partnerGender)
        self.callback = callback
    }
    
    var tableData: Driver<[AnimatableSectionModel<String, Row>]> {
        Observable.combineLatest(relationshipType, partnerGender).map { (relationshipType, partnerGender) in
            var result = [AnimatableSectionModel(model: "relationshipType", items: RelationshipType.allCases.map { Row.relationshipType($0, isSelected: $0 == relationshipType) })]
            if relationshipType != .single {
                result.append(AnimatableSectionModel(model: "partnerGender", items: Gender.allCases.map { Row.partnerGender($0, isSelected: $0 == partnerGender) }))
            }
            
            return result
        }.asDriver(onErrorJustReturn: [])
    }
    
    var partnerGenderError: Driver<Bool> {
        partnerGenderErrorRelay.asDriver()
    }
    
    func selectRelationshipType(index: Int) {
        self.relationshipType.accept(RelationshipType.allCases[index])
        partnerGenderErrorRelay.accept(false)
    }
    
    func selectPartnerGender(index: Int) {
        partnerGender.accept(Gender.allCases[index])
        partnerGenderErrorRelay.accept(false)
    }
    
    func back() {
        if validate() {
            callback?(RelationshipStatus(relationshipType: relationshipType.value, partnerGender: partnerGender.value))
            router.popBack()
        }
    }
    
    // MARK: - Private
    
    private let relationshipType: BehaviorRelay<RelationshipType>
    private let partnerGender: BehaviorRelay<Gender?>
    private let callback: ((RelationshipStatus) -> Void)?
    private var partnerGenderErrorRelay = BehaviorRelay<Bool>(value: false)
}

private extension EditRelationshipViewModel {
    
    func validate() -> Bool {
        partnerGenderErrorRelay.accept(relationshipType.value != .single && partnerGender.value == nil)
        return !partnerGenderErrorRelay.value
    }
}
