//
//  SinglePickViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/20/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

protocol SinglePickModel {
    var textRepresentation: String { get }
}

protocol SinglePickViewModelType {
    
    var models: [SinglePickModel] { get }
    var defaultModel: SinglePickModel? { get }
    
    var mode: SinglePickViewController.Mode { get }
    
    func picked(model: SinglePickModel)
    
    var title: String { get }
    
}

class SinglePickViewController: UIViewController {
    
    enum Mode {
        case table
        case picker
    }
    
    var viewModel: SinglePickViewModelType!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var saveButton: SecondaryButton!
    
    private let selectedPickerModel = BehaviorSubject<SinglePickModel?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = viewModel.mode != .table
        pickerContainer.isHidden = viewModel.mode != .picker
        saveButton.isHidden = viewModel.mode == .table
        
        switch viewModel.mode {
        case .table:
            backgroundView.backgroundColor = UIColor(fromHex: 0xF7F7F9)
            
        case .picker:
            backgroundView.backgroundColor = .white
        }
        
        titleLabel.text = viewModel.title
        view.addFantasyGradient()
        
        ///Picker
        
        let data = viewModel.models
        let picked = viewModel.defaultModel
        
        Observable.just(data)
            .bind(to: picker.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: item.textRepresentation,
                  attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.fantasyPink,
                    NSAttributedString.Key.font: UIFont.regularFont(ofSize: 25)
                ])
            }
            .disposed(by: rx.disposeBag)
        
        let index = data.firstIndex(where: { $0.textRepresentation == picked?.textRepresentation }) ?? 0
        picker.selectRow(index,
                         inComponent: 0, animated: false)
        
        picker.rx.modelSelected(SinglePickModel.self)
            .map { $0.first! }
            .bind(to: selectedPickerModel)
            .disposed(by: rx.disposeBag)

    }
    
    @IBAction func saveAction(_ sender: Any) {
        viewModel.picked(model: selectedPickerModel.unsafeValue!)
    }
    
}

extension SinglePickViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singlePickTableCell, for: indexPath)!
        
        let model = viewModel.models[indexPath.row]
        
        cell.pickLabel.text = model.textRepresentation
        cell.selectionButton.isSelected = false
        if let x = viewModel.defaultModel?.textRepresentation,
            model.textRepresentation == x {
            cell.selectionButton.isSelected = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = viewModel.models[indexPath.row]
        
        viewModel.picked(model: model)
        
    }
    
}