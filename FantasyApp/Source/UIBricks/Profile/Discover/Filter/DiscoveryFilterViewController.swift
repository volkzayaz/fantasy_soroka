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
    
    @IBOutlet weak var genderSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        genderSwitch.isOn = viewModel.prefs.gender == .male

    }
    
    @IBAction func genderChanged(_ sender: Any) {
        viewModel.change(gender:  genderSwitch.isOn ? .male : .female )
    }
    
    @IBAction func apply(_ sender: Any) {
        viewModel.submit()
    }
}

private extension DiscoveryFilterViewController {
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
