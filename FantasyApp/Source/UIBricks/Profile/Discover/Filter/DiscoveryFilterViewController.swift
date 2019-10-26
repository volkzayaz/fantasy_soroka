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
    @IBOutlet weak var activeCityImageView: UIImageView!

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

        if viewModel.showCancelButton {
            let item = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
            item.applyFantasyAttributes()
            navigationItem.rightBarButtonItem = item
        }

        // Input Data bindings

        let switchSignal =
            secondPartnerSwitch.rx.isOn.asDriver()

        switchSignal
            .map { !$0 }
            .drive(secondPartnerStackView.rx.isHidden)
            .disposed(by: rx.disposeBag)

        switchSignal.drive(onNext: { [unowned self] (x) in
            let c: RelationshipStatus = x ? .couple(partnerGender: self.viewModel.selectedSecondPartnerGender) : .single
            self.viewModel.changeCouple(x: c)
        }).disposed(by: rx.disposeBag)

        // Output Data bindings

        viewModel.community
            .map { $0?.name }
            .drive(onNext: { [unowned self] (name) in
                self.cityLabel.text = name
                self.activeCityImageView.image = name != nil ? R.image.cityCheckImage() : nil
            })
            .disposed(by: rx.disposeBag)

        secondPartnerSwitch.isOn = viewModel.isCouple
        partnerBodyPicker.firstselectedItem = viewModel.selectedPartnerGender
        partnerSexualityPicker.firstselectedItem =  viewModel.selectedPartnerSexuality
        secondPartnerBodyPicker.firstselectedItem = viewModel.selectedSecondPartnerGenderIndex
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

    @objc func cancel() {
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
        } else if pickerView == secondPartnerBodyPicker {
            viewModel.changeCouple(x: .couple(partnerGender: d as! Gender))
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
