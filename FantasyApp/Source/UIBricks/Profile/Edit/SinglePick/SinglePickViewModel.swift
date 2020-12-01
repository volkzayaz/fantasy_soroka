//
//  SinglePickViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension SinglePickViewModel {
    
    var models: [(String, [SinglePickModel])] {
        return _models
    }
    
    var pickedModels: [SinglePickModel] {
        return _pickedModels
    }
    
}

class SinglePickViewModel<T: SinglePickModel> : SinglePickViewModelType, MVVM_ViewModel {

    private let _models: [(String, [T])]
    private var _pickedModels: [T]
    let navigationTitle: String
    let title: String
    let mode: SinglePickViewController.Mode
    private let callback: ([T]) -> Void
    private let singlePickMode: Bool
    private let nonEmptySelectionMode: Bool
    
    init(router: SinglePickRouter,
         navigationTitle: String,
         title: String,
         models: [(String, [T])],
         pickedModels: [T],
         mode: SinglePickViewController.Mode,
         singlePickMode: Bool,
         nonEmptySelectionMode: Bool = false,
         result: @escaping ([T]) -> Void) {
        self.router = router
        self._models = models
        self._pickedModels = pickedModels
        self.navigationTitle = navigationTitle
        self.title = title
        self.mode = mode
        self.singlePickMode = singlePickMode
        self.nonEmptySelectionMode = nonEmptySelectionMode
        self.callback = result
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: SinglePickRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension SinglePickViewModel {
    
    func isPicked(model: SinglePickModel) -> Bool {
        _pickedModels.contains(where: { $0.textRepresentation == model.textRepresentation })
    }
    
    func pick(model: SinglePickModel) {
        
        if singlePickMode {
            _pickedModels = [model as! T]
            save()
            return
        }
        
        if let i = _pickedModels.firstIndex(where: { $0.textRepresentation == model.textRepresentation }) {
            let pickedModelsInCurrentGroupCount = _models.first { _, models -> Bool in
                models.contains { $0.textRepresentation == model.textRepresentation }
            }?.1.map { groupModel in
                _pickedModels.contains { $0.textRepresentation == groupModel.textRepresentation }
            }.filter { $0 }.count ?? 0
            
            if !nonEmptySelectionMode || pickedModelsInCurrentGroupCount > 1 {
                _pickedModels.remove(at: i)
            }
        } else {
            _pickedModels.append(model as! T)
        }
        
    }
    
    func save() {
        callback(_pickedModels)
        router.owner.navigationController?.popViewController(animated: true)
    }
    
}

extension Gender: SinglePickModel {
    
    var textRepresentation: String {
        return pretty
    }
    
}

extension Sexuality: SinglePickModel {
    
    var textRepresentation: String {
        return rawValue
    }
    
}

extension Pronoun: SinglePickModel {
    
    var textRepresentation: String {
        return pretty
    }
    
}

extension Expirience: SinglePickModel {
    
    var textRepresentation: String {
        return description
    }
    
}

extension LookingFor: SinglePickModel {
    
    var textRepresentation: String {
        return description
    }
    
}
