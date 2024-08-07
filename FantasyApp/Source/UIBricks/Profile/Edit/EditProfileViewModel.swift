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
                                         items: [Model.expandable(text: (user.bio.about ?? ""),
                                                                  placeholder: R.string.localizable.editProfileAbout(),
                                                                  maxLenth: 200,
                                                                  title: nil,
                                                                  editAction: self.changeAbout)])
                
                let account = SectionModel(model: R.string.localizable.editProfileAccount(),
                                           items: [Model.attribute(user.bio.name,
                                                                   value: "",
                                                                   image: R.image.profileName()!,
                                                                   editAction: nil),
                                                   .attribute(R.string.localizable.profileDiscoverUserYears(user.bio.yearsOld),
                                                              value: "",
                                                              image: R.image.profileBirthday()!,
                                                              editAction: nil),
                                                   .attribute(R.string.localizable.editProfileBody(),
                                                              value: user.bio.gender.pretty,
                                                              image: R.image.profileGender()!,
                                                              editAction: nil),
                                                   .attribute(R.string.localizable.editProfileSexuaity(),
                                                              value: user.bio.sexuality.pretty,
                                                              image: R.image.profileSexuality()!,
                                                              editAction: nil),
                                                   .attribute(R.string.localizable.editProfileRelationship(),
                                                              value: user.bio.relationshipStatus?.pretty ?? "",
                                                              image: R.image.profileRelationships()!,
                                                              editAction: self.changeRelationship),
                                                   .attribute(R.string.localizable.editProfilePronoun(),
                                                              value: user.bio.pronoun?.pretty ?? "",
                                                              image: R.image.profilePronoun()!,
                                                              editAction: self.changePronoun)
                    ])
                
                
                let lookingFor: String
                if user.bio.lookingFor.count > 0 {
                    lookingFor = user.bio.lookingFor.map { $0.description }.joined(separator: ", ")
                }
                else {
                    lookingFor = R.string.localizable.editProfileChoose()
                }
                
                let community = SectionModel(model: R.string.localizable.editProfilePrefs(),
                                         items:
                    [
                        Model.attribute(R.string.localizable.editProfileActiveCity(),
                                        value: user.community.value?.name ?? R.string.localizable.editProfileNoCommunity(),
                                        image: R.image.profileCommunity()!,
                                        editAction: self.changeActiveCity),
                        Model.attribute(R.string.localizable.editProfileExperience(),
                                        value: user.bio.expirience?.description ?? R.string.localizable.editProfileChoose(),
                                        image: R.image.profileExpirience()!,
                                        editAction: self.changeExpirience),
                        Model.attribute(R.string.localizable.editProfileLookingFor(),
                                        value: lookingFor,
                                        image: R.image.profileLookingFor()!,
                                        editAction: self.changeLookingFor),
                ])
                
                let q1 = User.Bio.PersonalQuestion.question1
                let q2 = User.Bio.PersonalQuestion.question2
                let q3 = User.Bio.PersonalQuestion.question3
                
                let questions = SectionModel(model: R.string.localizable.editProfileAnswers(),
                                         items:
                    [
                        Model.expandable(text: user.bio.answers[q1] ?? "",
                                         placeholder: R.string.localizable.editProfileQuestionPlaceholder(),
                                         maxLenth: 100,
                            title: q1,
                            editAction: { self.change(answer: $0, to: q1) }),
                        
                        Model.expandable(text: user.bio.answers[q2] ?? "",
                                         placeholder: R.string.localizable.editProfileQuestionPlaceholder(),
                                         maxLenth: 100,
                                         title: q2,
                                         editAction: { self.change(answer: $0, to: q2) }),
                        
                        Model.expandable(text: user.bio.answers[q3] ?? "",
                                         placeholder: R.string.localizable.editProfileQuestionPlaceholder(),
                                         maxLenth: 100,
                                         title: q3,
                                         editAction: { self.change(answer: $0, to: q3) }),
                        
                ])
                    
                return [about, account, community, questions]
                
            }
        
    }
    
    func profilePhotoRouter(for owner: EditProfilePhotoCell) -> ProfilePhotoRouter {
        return .init(owner: owner, container: router.owner)
    }
    
}

class EditProfileViewModel : MVVM_ViewModel {
    
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
      case expandable(text: String, placeholder: String, maxLenth: Int, title: String?, editAction: ((String?) -> Void)?)
        case attribute(String, value: String, image: UIImage, editAction: (() -> Void)?)
    }
    
}

extension EditProfileViewModel {
    
    func preview() {
        router.preview(user: User.current!.applied(editForm: form.value))
    }
    
    func changeLookingFor() {
        router.presentSinglePick(navigationTitle: R.string.localizable.editProfileLookingFor(),
                                 title: R.string.localizable.editProfileChangeLookingForTitle(),
                                 models: LookingFor.sortedCases,
                                 defaultModels: User.current!.applied(editForm: form.value).bio.lookingFor,
                                 mode: .table,
                                 singlePickMode: false,
                                 nonEmptySelectionMode: true) { x in self.updateForm { $0.lookingFor = x } }
    }
    
    func changeExpirience() {
        
        var defaultModel: [Expirience] = []
        if let x = User.current!.applied(editForm: form.value).bio.expirience {
            defaultModel = [x]
        }
        
        router.presentSinglePick(navigationTitle: R.string.localizable.editProfileExperience(),
                                 title: R.string.localizable.editProfileChangeExpirienceTitle(),
                                 models: [("", Expirience.allCases)],
                                 defaultModels: defaultModel,
                                 mode: .table,
                                 singlePickMode: true) { x in self.updateForm { $0.expirience = x.first } }
    }
    
    func changeGender() {
        router.presentSinglePick(navigationTitle: R.string.localizable.editProfileBody(),
                                 title: R.string.localizable.editProfileChangeGenderTitle(),
                                 models: [("", Gender.allCases)],
                                 defaultModels: [User.current!.applied(editForm: form.value).bio.gender],
                                 mode: .picker,
                                 singlePickMode: true) { x in self.updateForm { $0.gender = x.first! } }
    }
    
    func changeSexuality() {
        router.presentSinglePick(navigationTitle: R.string.localizable.editProfileSexuaity(),
                                 title: R.string.localizable.editProfileChangeSexualityTitle(),
                                 models: [("", Sexuality.allCasesV2)],
                                 defaultModels: [User.current!.applied(editForm: form.value).bio.sexuality],
                                 mode: .picker,
                                 singlePickMode: true) { x in self.updateForm { $0.sexuality = x.first! } }
    }
    
    func changeRelationship() {
        router.presentRelationship(status: User.current!.applied(editForm: form.value).bio.relationshipStatus) { x in self.updateForm { $0.relationshipStatus = x } }
    }
    
    func changePronoun() {
        let defaultModels = User.current!.applied(editForm: form.value).bio.pronoun.map { [$0] } ?? []
        router.presentSinglePick(navigationTitle: R.string.localizable.editProfilePronoun(),
                                 title: R.string.localizable.editProfileChangePronounTitle(),
                                 models: [("", Pronoun.allCases)],
                                 defaultModels: defaultModels,
                                 mode: .table,
                                 singlePickMode: true) { x in self.updateForm { $0.pronoun = x.first } }
    }
    
    func changeActiveCity() {
        router.presentTeleport(form: form)
    }

    func changeAbout(answer: String?) {
        self.updateForm { $0.about = answer }
    }
    
    func change(answer: String?, to question: String) {
        self.updateForm { $0.answers[question] = answer }
    }
    
    private func updateForm(_ mapper: (inout EditProfileForm) -> Void ) {
        var x = form.value
        mapper(&x)
        form.accept(x)
    }
    
}
