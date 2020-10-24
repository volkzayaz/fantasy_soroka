//
//  EditProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

struct EditProfileRouter : MVVM_Router {
    
    unowned private(set) var owner: EditProfileViewController
    init(owner: EditProfileViewController) {
        self.owner = owner
    }
    
    func preview(user: User) {
        
        let x = R.storyboard.user.userProfileViewController()!
        x.viewModel = .init(router: .init(owner: x), user: user)
        let navigationController = FantasyNavigationController(rootViewController: x)
        navigationController.modalPresentationStyle = .overFullScreen
        owner.navigationController?.present(navigationController, animated: true, completion: nil)
        
    }
    
    func presentTeleport(form: BehaviorRelay<EditProfileForm>) {
        
        let x = R.storyboard.user.teleportViewController()!
        x.viewModel = .init(router: .init(owner: x), response: .editForm(form))
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
    func presentSinglePick<T: SinglePickModel>(title: String,
                                               models: [(String, [T])],
                                               defaultModels: [T],
                                               mode: SinglePickViewController.Mode,
                                               singlePickMode: Bool,
                                               result: @escaping ([T]) -> Void) {
        
        let x = R.storyboard.userGateway.singlePickViewController()!
        x.viewModel = SinglePickViewModel(router: .init(owner: x),
                                          title: title,
                                          models: models,
                                          pickedModels: defaultModels,
                                          mode: mode,
                                          singlePickMode: singlePickMode,
                                          result: result)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
    func presentRelationship(status: RelationshipStatus,
                             callback: @escaping (RelationshipStatus) -> Void) {
        let x = R.storyboard.userGateway.editRelationshipViewController()!
        x.defaultStatus = status
        x.callback = callback
        owner.navigationController?.pushViewController(x, animated: true)
    }
    
}
