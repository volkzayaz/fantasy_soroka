//
//  CommonFantasiesViewController.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources

class CommonFantasiesViewController: UIViewController, MVVM_View {
    var viewModel: CommonFantasiesViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension CommonFantasiesViewController {
    func configure() {
        
    }
}
