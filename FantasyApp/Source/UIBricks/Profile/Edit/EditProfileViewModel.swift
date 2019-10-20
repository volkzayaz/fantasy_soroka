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
                        Model.attribute("Expience",
                                        value: user.bio.expirience?.description ?? "Choose"),
                ])
                
                let q1 = User.Bio.PersonalQuestion.question1
                let q2 = User.Bio.PersonalQuestion.question2
                let q3 = User.Bio.PersonalQuestion.question3
                
                let questions = SectionModel(model: R.string.localizable.editProfileAnswers(),
                                         items:
                    [
                        Model.about("\(q1)\n \(user.bio.answers[q1] ?? "")"),
                        Model.about("\(q2)\n \(user.bio.answers[q2] ?? "")"),
                        Model.about("\(q3)\n \(user.bio.answers[q3] ?? "")")
                ])
                
                return [about, account, community, questions]
                
            }
        
        
        
    }
    
    func profilePhotoRouter(for owner: EditProfilePhotoCell) -> ProfilePhotoRouter {
        return .init(owner: owner, container: router.owner)
    }
    
}

struct EditProfileViewModel : MVVM_ViewModel {
    
    ////soure of truth
    fileprivate let form = BehaviorRelay(value: EditProfileForm(answers: User.current!.bio.answers))
    
    init(router: EditProfileRouter) {
        self.router = router
        
        ///Stakeholders insist on submitting every change to server instead of only once
        
        form.skip(1) // initial value
            .flatMapLatest { form in
                return UserManager.submitEdits(form: form)
                    .silentCatch(handler: router.owner)
            }
            .subscribe(onNext: { (user) in
                
                ///this state save should really belong elsewhere
                SettingsStore.currentUser.value = user
                
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)
        
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
    
    func changed(about: String) {
        updateForm { $0.about = about }
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
        
        if ip.section == 2 && ip.row == 2 {
            
            router.owner.showTextQuestionDialog(title: "Choose", text: "Expirience") { (str) in
                
                guard let int = Int(str), let value = Expirience(rawValue: int) else {
                    return
                }
                
                self.updateForm { $0.expirience = value }
                
            }
         
        }
        
        if ip.section == 0 && ip.row == 0 {
            
            router.owner.showTextQuestionDialog(title: "About", text: "") { (str) in
                
                self.updateForm { $0.about = str }
                
            }
            
        }
        
        if ip.section == 3 {
            
            let q = [User.Bio.PersonalQuestion.question1,
                     User.Bio.PersonalQuestion.question2,
                     User.Bio.PersonalQuestion.question3][ip.row]
            
            router.owner.showTextQuestionDialog(title: q, text: "") { (str) in
                
                self.updateForm { $0.answers[q] = str }
                
            }
            
        }
        
    }
    
    private func updateForm(_ mapper: (inout EditProfileForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
