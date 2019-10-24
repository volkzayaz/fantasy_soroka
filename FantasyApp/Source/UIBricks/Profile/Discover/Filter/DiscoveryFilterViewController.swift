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
import RxDataSources

class DiscoveryFilterViewController: UIViewController, MVVM_View {
    
    var viewModel: DiscoveryFilterViewModel!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 44.0
        }
    }

    lazy var sectionsTableDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, DiscoveryFilterViewModel.Row>>(configureCell: { [unowned self] (_, tv, ip, section) in

        switch section {
        case .city(let x):
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.filterSelectCityCell, for: ip)!
            cell.setData(value: x)
            return cell

        case .partnerBody(let title, let description, let list, let selected),
             .partnerSexuality(let title, let description, let list, let selected),
             .secondPartnerBody(let title, let description, let list, let selected),
             .secondPartnerSexuality(let title, let description, let list, let selected):

            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.filterSwipeableCell, for: ip)!
            cell.setData(title: title, description: description, list: list, selected: selected)
            return cell

        case .age(let from, let to):
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.filterAgeSliderCell, for: ip)!
            cell.setData(minValue: from, maxValue: to)
            return cell

        case .couple(let isOn):
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.filterSwitchableCell, for: ip)!
            cell.setData(isOn: isOn)
            return cell

        }

    })

    let sectionsInfo: [(Int, CGFloat, String?)] = [
        (0, 42.0, "Teleport"),
        (1, 46.0, "Partner"),
        (2, 11.0, nil),
        (3, 11.0, nil),
        (4, 32.0, nil),
        (5, 46.0,"Second Partner"),
        (6, 11.0, nil),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyTripleGradient()
        tableView.addFantasyRoundedCorners()

        viewModel.sections
            .map { $0.map { AnimatableSectionModel(model: $0.0, items: $0.1) } }
            .drive(tableView.rx.items(dataSource: sectionsTableDataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
      
//        if let x = [Gender.male: 1,
//        Gender.female: 2,
//        Gender.transgenderMale: 3,
//        Gender.transgenderFemale: 4,
//        Gender.nonBinary: 5][viewModel.prefs.gender] {
//            genderTextField.text = String(x)
//        }
//
//        if let x = [Sexuality.straight: 1,
//        Sexuality.gay: 2,
//        Sexuality.lesbian: 3,
//        Sexuality.bisexual: 4][viewModel.prefs.sexuality] {
//            sexualityTextField.text = String(x)
//        }
//
//        ageFromTextField.text = String(viewModel.prefs.age.lowerBound)
//        ageToTextField.text = String(viewModel.prefs.age.upperBound)
      
    }

}

//MARK:- Actions

extension DiscoveryFilterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let t = sectionsInfo[section].2 else {
            return UIView()
        }

        let headerView = FilterSectionHeaderView()
        headerView.setData(value: t)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionsInfo[section].1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

//MARK:- Actions

extension DiscoveryFilterViewController {

    @IBAction func cancel(_ sender: Any) {
        viewModel.cancel()
    }

    @IBAction func apply(_ sender: Any) {
        view.endEditing(true)

        viewModel.submit()
    }

    
    @IBAction func openTeleport(_ sender: Any) {
        viewModel.openTeleport()
    }

}

//
//extension DiscoveryFilterViewController: UITextFieldDelegate {
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//        if textField == genderTextField {
//
//            if let gender = [1: Gender.male,
//            2: Gender.female,
//            3: Gender.transgenderMale,
//            4: Gender.transgenderFemale,
//            5: Gender.nonBinary][Int(textField.text ?? "") ?? 0] {
//                viewModel.change(gender: gender)
//            }
//
//        }
//        else if textField == sexualityTextField {
//
//            if let sexuality = [1: Sexuality.straight,
//                             2: Sexuality.gay,
//                             3: Sexuality.lesbian,
//                             4: Sexuality.bisexual][Int(textField.text ?? "") ?? 0] {
//                viewModel.change(sexuality: sexuality)
//            }
//
//        }
//        else if textField == ageFromTextField {
//            viewModel.changeAgeFrom(x: Int(textField.text ?? "") ?? 18)
//        }
//        else if textField == ageToTextField {
//            viewModel.changeAgeTo(x: Int(textField.text ?? "") ?? 60)
//        }
//
//        return true
//    }
//}
