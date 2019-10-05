//
//  EditProfileViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension EditProfileViewModel {
    
    var dataSource: Driver<[SectionModel<String, Model>]> {
     
        let user = User.current!
        
        return form.asDriver()
            .map { user.applied(editForm: $0) }
            .map { user in
                
                ////TODO: split separate texts into own translation tables instead of dot prefixing
                ////usage of dot prefixes creates a lot of redundant prefix mentions in client code
                let about = SectionModel(model: R.string.localizable.editProfileAbout(),
                                         items: [Model.about(user.bio.about ?? "")])
                
                let account = SectionModel(model: R.string.localizable.editProfileAccount(),
                                           items: [Model.attribute(R.string.localizable.editProfileName(),
                                                                   value: user.bio.name),
                                                   .attribute(R.string.localizable.editProfileAge(),
                                                              value: user.bio.birthday.description),
                                                   .attribute(R.string.localizable.editProfileBody(),
                                                              value: user.bio.gender.rawValue),
                                                   .attribute(R.string.localizable.editProfileSexuaity(),
                                                              value: user.bio.sexuality.rawValue),
                                                   .attribute(R.string.localizable.editProfileRelationship(),
                                                              value: user.bio.relationshipStatus.description)
                    ])
                
                let community = SectionModel(model: R.string.localizable.editProfileAbout(),
                                         items:
                    [
                        Model.attribute("Active city",
                                        value: user.community.value?.name ?? "No community"),
                        Model.attribute("Looking for",
                                        value: user.bio.lookingFor?.description ?? "Choose"),
                ])
                
                return [about, account, community]
                
            }
        
        
        
    }
    
    func profilePhotoRouter(for owner: EditProfilePhotoCell) -> ProfilePhotoRouter {
        return .init(owner: owner, container: router.owner)
    }
    
}

struct EditProfileViewModel : MVVM_ViewModel {
    
    ////soure of truth
    fileprivate let form = BehaviorRelay(value: EditProfileForm())
    
    init(router: EditProfileRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: EditProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
 
    enum Model {
        case about(String)
        case attribute(String, value: String)
    }
    
}

extension EditProfileViewModel {
    
    func preview() {
        
        router.preview(user: User.current!.applied(editForm: form.value))
    }
    
    func submitChanges() {
        
        let edits = form.value
        
        UserManager.submitEdits(form: edits)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (user) in
                
                ///this state save should really belong elsewhere
                SettingsStore.currentUser.value = user
                
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)
    }
    
    func cellClicked(ip: IndexPath) {
        
        if ip.section == 2 && ip.row == 0 {
            router.presentTeleport(form: form)
        }
        
        if ip.section == 2 && ip.row == 1 {
            
            router.owner.showTextQuestionDialog(title: "Choose", text: "Looking for") { (str) in
                
                guard let int = Int(str), let value = LookingFor(rawValue: int) else {
                    return
                }
                
                self.updateForm { $0.lookingFor = value }
                
            }
         
        }
        
        if ip.section == 0 && ip.row == 0 {
            
            router.owner.showTextQuestionDialog(title: "About", text: "") { (str) in
                
                self.updateForm { $0.about = str }
                
            }
            
            router.presentTeleport(form: form)
        }
    }
    
    private func updateForm(_ mapper: (inout EditProfileForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
