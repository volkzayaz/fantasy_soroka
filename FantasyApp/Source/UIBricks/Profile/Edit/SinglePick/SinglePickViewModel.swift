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
    
    var models: [SinglePickModel] {
        return _models
    }
    
    var defaultModel: SinglePickModel? {
        return _defaultModel
    }
    
}

struct SinglePickViewModel<T: SinglePickModel> : SinglePickViewModelType, MVVM_ViewModel {

    private let _models: [T]
    private let _defaultModel: T?
    let title: String
    let mode: SinglePickViewController.Mode
    private let callback: (T) -> Void
    
    init(router: SinglePickRouter,
         title: String,
         models: [T],
         defaultModel: T?,
         mode: SinglePickViewController.Mode,
         result: @escaping (T) -> Void) {
        self.router = router
        self._models = models
        self._defaultModel = defaultModel
        self.title = title
        self.mode = mode
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
    
    func picked(model: SinglePickModel) {
        callback(model as! T)
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
