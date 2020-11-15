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


class DiscoveryFilterViewController: UIViewController, MVVM_View {
    
    var viewModel: DiscoveryFilterViewModel!

    // City section
    @IBOutlet weak var citySectionView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var activeCityImageView: UIImageView!

    // Partner section
    @IBOutlet weak var partnerBodyPicker: SmoothPickerView!
    @IBOutlet weak var partnerSexualityPicker: SmoothPickerView!
    @IBOutlet weak var ageSlider: MultiSlider! {
        didSet {
            ageSlider.thumbImage = R.image.sliderThumbImage()
            ageSlider.orientation = .horizontal
            ageSlider.valueLabelPosition = .notAnAttribute
            ageSlider.minimumValue = 21.0
            ageSlider.maximumValue = 100.0
            ageSlider.snapStepSize = 1.0
            ageSlider.trackWidth = 2
            ageSlider.showsThumbImageShadow = false
            ageSlider.keepsDistanceBetweenThumbs = true
            ageSlider.distanceBetweenThumbs = 10
            ageSlider.outerTrackColor = R.color.listBackgroundColor()
            ageSlider.tintColor = R.color.textPinkColor()
            ageSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        }
    }

    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.addFantasyRoundedCorners()
            scrollView.backgroundColor = R.color.listBackgroundColor()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addFantasyTripleGradient()

        let item = UIBarButtonItem(title: R.string.localizable.generalCancel(), style: .done, target: self, action: #selector(cancel))
        item.applyFantasyAttributes()
        navigationItem.rightBarButtonItem = item

        partnerBodyPicker.firstselectedItem = viewModel.selectedPartnerGender
        partnerSexualityPicker.firstselectedItem =  viewModel.selectedPartnerSexuality

        ageSlider.value = [viewModel.age.lowerBound, viewModel.age.upperBound].map { CGFloat ($0) }

        // Output Data bindings
        viewModel.community
            .map { $0?.name }
            .drive(onNext: { [unowned self] (name) in
                self.cityLabel.text = name
                self.activeCityImageView.image = name != nil ? R.image.cityCheckImage() : nil
            })
            .disposed(by: rx.disposeBag)

        viewModel.showLocationSection
            .map { !$0 }
            .drive(citySectionView.rx.isHidden)
        .disposed(by: rx.disposeBag)

        // apply text color and fonts to slider labels
        ageSlider.valueLabels.forEach {
            $0.font = UIFont.regularFont(ofSize: 15)
            $0.textColor = R.color.textBlackColor()
        }
        
        viewModel.ageDriver
            .map { R.string.localizable.profileDiscoverFilterAge("\($0.lowerBound)", "\($0.upperBound)") }
            .drive(ageLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    var smoothPickerHack = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        smoothPickerHack = true
    }
    
}

//MARK:- Actions

extension DiscoveryFilterViewController {

    @objc func cancel() {
        viewModel.cancel()
    }

    @objc func sliderChanged(_ slider: MultiSlider) {
        viewModel.changeAge(x: Int(slider.value.first!)..<Int(slider.value.last!))
    }

    @IBAction func apply(_ sender: Any) {
        view.endEditing(true)
        viewModel.submit()
    }
    
    @IBAction func openTeleport(_ sender: Any) {
        viewModel.openTeleport()
    }
}

//MARK:- SmoothPickerViewDelegate, SmoothPickerViewDataSource

extension DiscoveryFilterViewController: SmoothPickerViewDelegate, SmoothPickerViewDataSource {

    func didSelectItem(index: Int, view: UIView, pickerView: SmoothPickerView) {

        ///smooth picker calls this method for initial view load even though nobody selected anything
        ///internal bug in the library
        guard smoothPickerHack else { return }
        
        guard let v = view as? SwipeView,
            let d = v.data else  { return }

        if pickerView == partnerBodyPicker {
            viewModel.changePartnerGender(gender: d as! Gender)
        } else if pickerView == partnerSexualityPicker  {
            viewModel.changePartnerSexuality(sexuality: d as! Sexuality)
        }
    }

    func numberOfItems(pickerView: SmoothPickerView) -> Int {

        if pickerView == partnerBodyPicker {
            return viewModel.bodiesCount
        }

        return viewModel.sexualityCount
    }

    func itemForIndex(index: Int, pickerView: SmoothPickerView) -> UIView {

        let itemView = SwipeView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))

        if pickerView == partnerBodyPicker {

            itemView.data = Gender.gender(by: index)

            return itemView
        }

        itemView.data = Sexuality.sexuality(by: index)

        return itemView
    }

}
