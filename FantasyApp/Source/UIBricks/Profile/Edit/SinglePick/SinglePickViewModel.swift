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

struct SinglePickViewModel<T: SinglePickModel> : SinglePickViewModelType, MVVM_ViewModel {

    private let _models: [(String, [T])]
    private var _pickedModels: [T]
    let title: String
    let mode: SinglePickViewController.Mode
    private let callback: ([T]) -> Void
    private let singlePickMode: Bool
    
    init(router: SinglePickRouter,
         title: String,
         models: [(String, [T])],
         pickedModels: [T],
         mode: SinglePickViewController.Mode,
         singlePickMode: Bool,
         result: @escaping ([T]) -> Void) {
        self.router = router
        self._models = models
        self._pickedModels = pickedModels
        self.title = title
        self.mode = mode
        self.singlePickMode = singlePickMode
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
    
    mutating func picked(model: SinglePickModel) {
        
        if singlePickMode {
            _pickedModels = [model as! T]
            save()
            return
        }
        
        if let i = _pickedModels.firstIndex(where: { $0.textRepresentation == model.textRepresentation }) {
            _pickedModels.remove(at: i)
        }
        else {
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
