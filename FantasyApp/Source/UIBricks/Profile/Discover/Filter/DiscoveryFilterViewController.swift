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

import SmoothPicker
import MultiSlider


class DiscoveryFilterViewController: UIViewController, MVVM_View {
    
    var viewModel: DiscoveryFilterViewModel!

    // City section
    @IBOutlet weak var tutorialView: UIView!

    // City section
    @IBOutlet weak var cityLabel: UILabel!

    // Partner section
    @IBOutlet weak var partnerBodyPicker: SmoothPickerView!
    @IBOutlet weak var partnerSexualityPicker: SmoothPickerView!
    @IBOutlet weak var ageSlider: MultiSlider! {
        didSet {
            ageSlider.minimumValue = 18.0
            ageSlider.maximumValue = 100.0
            ageSlider.orientation = .horizontal
            ageSlider.valueLabelPosition = .bottom
            ageSlider.snapStepSize = 1.0

            ageSlider.outerTrackColor = .gray
            ageSlider.value = [30, 31]
            ageSlider.tintColor = .purple
            ageSlider.trackWidth = 11
            ageSlider.showsThumbImageShadow = false
            ageSlider.keepsDistanceBetweenThumbs = true
        }
    }

    // Couple section
    @IBOutlet weak var secondPartnerSwitch: UISwitch! {
           didSet {
               secondPartnerSwitch.onTintColor = R.color.textPinkColor()
           }
       }

    // Second partner section
    @IBOutlet weak var secondPartnerBodyPicker: SmoothPickerView!
    @IBOutlet weak var secondPartnerSexualityPicker: SmoothPickerView!

    // Common
    @IBOutlet weak var secondPartnerStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.addFantasyRoundedCorners()
            scrollView.backgroundColor = R.color.listBackgroundColor()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyTripleGradient()

        // Input Data bindings

        let switchSignal =
            secondPartnerSwitch.rx.isOn.asDriver()

        switchSignal
            .map { !$0 }
            .drive(secondPartnerStackView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        switchSignal.drive(onNext: { [unowned self] (x) in
            self.viewModel.changeCouple(x: x)
        }).disposed(by: rx.disposeBag)

        // Output Data bindings

        viewModel.community
            .map { $0?.name }
            .drive(cityLabel.rx.text)
            .disposed(by: rx.disposeBag)

        secondPartnerSwitch.isOn = viewModel.isCouple
        partnerBodyPicker.firstselectedItem = viewModel.selectedPartnerGender
        partnerSexualityPicker.firstselectedItem =  viewModel.selectedPartnerSexuality
        secondPartnerSexualityPicker.firstselectedItem = viewModel.selectedSecondPartnerSexuality
        secondPartnerBodyPicker.firstselectedItem = viewModel.selectedSecondPartnerGender
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.showTutorial {

            guard let v = self.navigationController?.view else { return }

            v.addSubview(self.tutorialView)

            tutorialView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            viewModel.updateTutorial(true)
        }
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

    @IBAction func tutorialClose(_ sender: Any) {
        tutorialView.removeFromSuperview()
    }

    @IBAction func tutorialGotIt(_ sender: Any) {
        tutorialView.removeFromSuperview()
    }
}

//MARK:- SmoothPickerViewDelegate, SmoothPickerViewDataSource

extension DiscoveryFilterViewController: SmoothPickerViewDelegate, SmoothPickerViewDataSource {

    func didSelectItem(index: Int, view: UIView, pickerView: SmoothPickerView) {

        guard let v = view as? SwipeView,
            let d = v.data else  { return }

        if pickerView == partnerBodyPicker {
            viewModel.changePartnerGender(gender: d as! Gender)
        } else if pickerView == partnerSexualityPicker  {
            viewModel.changePartnerSexuality(sexuality: d as! Sexuality)
        } else if pickerView == secondPartnerSexualityPicker {
            viewModel.changeSecondPartnerSexuality(sexuality: d as! Sexuality)
        } else if pickerView == secondPartnerBodyPicker {
            viewModel.changeSecondPartnerGender(gender: d as! Gender)
        }
    }

    func numberOfItems(pickerView: SmoothPickerView) -> Int {

        if pickerView == partnerBodyPicker
            || pickerView == secondPartnerBodyPicker {
            return viewModel.bodiesCount
        }

        return viewModel.sexualityCount
    }

    func itemForIndex(index: Int, pickerView: SmoothPickerView) -> UIView {

        let itemView = SwipeView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))

        if pickerView == partnerBodyPicker
            || pickerView == secondPartnerBodyPicker {

            itemView.data = Gender.gender(by: index)

            return itemView
        }

        itemView.data = Sexuality.sexuality(by: index)

        return itemView
    }

}
