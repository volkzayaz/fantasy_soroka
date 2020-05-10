//
//  UpdateAppViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 04.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

class UpdateAppViewController: UIViewController {

    @IBOutlet weak var buyButton: PrimaryButton! {
        didSet {
            buyButton.mode = .selector
            buyButton.titleFont = .boldFont(ofSize: 16)
            buyButton.addFantasyGradient()
        }
    }
    @IBOutlet weak var daView: UIView! {
        didSet {
            daView.addFantasyRoundedCorners()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyGradient()
        title = R.string.localizable.onboardingUpdateTitle()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateApp(_ sender: Any) {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1230109516?mt=8"
        
        UIApplication.shared
            .open(URL(string: urlStr)!, options: [:], completionHandler: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
