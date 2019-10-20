//
//  DiscoveryFilterViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class DiscoveryFilterViewController: UIViewController, MVVM_View {
    
    var viewModel: DiscoveryFilterViewModel!
    
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sexualityTextField: UITextField!
    
    @IBOutlet weak var ageFromTextField: UITextField!
    @IBOutlet weak var ageToTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let x = [Gender.male: 1,
        Gender.female: 2,
        Gender.transgenderMale: 3,
        Gender.transgenderFemale: 4,
        Gender.nonBinary: 5][viewModel.prefs.gender] {
            genderTextField.text = String(x)
        }
        
        if let x = [Sexuality.straight: 1,
        Sexuality.gay: 2,
        Sexuality.lesbian: 3,
        Sexuality.bisexual: 4][viewModel.prefs.sexuality] {
            sexualityTextField.text = String(x)
        }
        
        ageFromTextField.text = String(viewModel.prefs.age.lowerBound)
        ageToTextField.text = String(viewModel.prefs.age.upperBound)
      
    }
    
    @IBAction func openTeleport(_ sender: Any) {
        viewModel.openTeleport()
    }
    
    @IBAction func apply(_ sender: Any) {
        view.endEditing(true)
        
        viewModel.submit()
    }
}

extension DiscoveryFilterViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == genderTextField {
            
            if let gender = [1: Gender.male,
            2: Gender.female,
            3: Gender.transgenderMale,
            4: Gender.transgenderFemale,
            5: Gender.nonBinary][Int(textField.text ?? "") ?? 0] {
                viewModel.change(gender: gender)
            }
            
        }
        else if textField == sexualityTextField {
            
            if let sexuality = [1: Sexuality.straight,
                             2: Sexuality.gay,
                             3: Sexuality.lesbian,
                             4: Sexuality.bisexual][Int(textField.text ?? "") ?? 0] {
                viewModel.change(sexuality: sexuality)
            }
            
        }
        else if textField == ageFromTextField {
            viewModel.changeAgeFrom(x: Int(textField.text ?? "") ?? 18)
        }
        else if textField == ageToTextField {
            viewModel.changeAgeTo(x: Int(textField.text ?? "") ?? 60)
        }
        
        return true
    }
    

    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
