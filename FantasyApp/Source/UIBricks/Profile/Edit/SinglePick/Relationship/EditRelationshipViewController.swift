//
//  EditRelationshipViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

class EditRelationshipViewController: UIViewController {
    
    @IBOutlet weak var soloButton: PrimaryButton! {
        didSet {
            soloButton.normalBackgroundColor = UIColor.fantasyPink
            soloButton.disabledBackgroundColor = UIColor.fantasyGrey
            soloButton.mode = .selector
        }
    }
    @IBOutlet weak var coupleButton: PrimaryButton! {
        didSet {
            coupleButton.normalBackgroundColor = UIColor.fantasyPink
            coupleButton.disabledBackgroundColor = UIColor.fantasyGrey
            coupleButton.mode = .selector
        }
    }
    
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var partnerPicker: UIPickerView!
    
    private let model = BehaviorSubject<RelationshipStatus>(value: .single)
    
    
    var defaultStatus: RelationshipStatus!
    var callback: ((RelationshipStatus) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        
        model.onNext(defaultStatus)
        
        let data = Gender.allCases
        
        Observable.just(data)
            .bind(to: partnerPicker.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.textRepresentation,
                  attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.fantasyPink,
                    NSAttributedString.Key.font: UIFont.regularFont(ofSize: 25)
                ])
            }
            .disposed(by: rx.disposeBag)
        
        model
            .subscribe(onNext: { [unowned self] (status) in
                
                switch status {
                    
                case .single:
                    self.soloButton.isSelected = true
                    self.coupleButton.isSelected = false
                    
                    self.partnerLabel.isHidden = true
                    self.partnerPicker.isHidden = true
                    
                case .couple(let gender):
                    
                    self.soloButton.isSelected = false
                    self.coupleButton.isSelected = true
                    
                    self.partnerLabel.isHidden = false
                    self.partnerPicker.isHidden = false
                    
                    self.partnerPicker.selectRow(data.firstIndex(of: gender)!,
                                                 inComponent: 0, animated: false)
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        partnerPicker.rx.modelSelected(Gender.self)
            .map { RelationshipStatus.couple(partnerGender: $0.first!) }
            .bind(to: model)
            .disposed(by: rx.disposeBag)

    }
    
    
    @IBAction func soloButton(_ sender: Any) {
        model.onNext(.single)
    }
    
    @IBAction func partnerAction(_ sender: Any) {
        model.onNext(.couple(partnerGender: .female))
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        callback?(model.unsafeValue)
        navigationController?.popViewController(animated: true)
    }
    
}
