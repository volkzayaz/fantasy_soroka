//
//  FlirtAccessViewController.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 5/27/20.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit
import SnapKit

final class FlirtAccessViewController: UIViewController, MVVM_View {
    
    var viewModel: FlirtAccessViewModel!
    
    @IBOutlet weak var activateView: UIView!
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var checkActivateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activateButton.isEnabled = false
        checkActivateButton.isSelected = false
        
        view.addSubview(activateView)
        activateView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
        }
        activateView.addFantasyRoundedCorners()
    }
    
    @IBAction func activateClick(_ sender: UIButton) {
        viewModel.activateFlirtAccess()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func activateTickClick(_ sender: UIButton) {
        activateButton.isEnabled = sender.isSelected
    }
    
    @IBAction func activateTextClick(_ sender: Any) {
        checkActivateButton.sendActions(for: .touchUpInside)
    }
}
