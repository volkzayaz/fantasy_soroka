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
    
    var models: [(String, [SinglePickModel])] { get }
    var pickedModels: [SinglePickModel] { get }
    
    var mode: SinglePickViewController.Mode { get }
    
    mutating func picked(model: SinglePickModel)
    
    var navigationTitle: String { get }
    var title: String { get }
    
    func save() 
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
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back(),
                                                               style: .plain, target: self, action: "save")
            
            
        case .picker:
            backgroundView.backgroundColor = .white
        }
        
        title = viewModel.navigationTitle
        titleLabel.text = viewModel.title
        view.addFantasyGradient()
        
        ///Picker
        
        let data = viewModel.models.flatMap { $0.1 }
        let picked = viewModel.pickedModels.first
        
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

        guard let value = selectedPickerModel.unsafeValue else {
            return
        }

        viewModel.picked(model: value)
    }
    
    @objc func save() {
        viewModel.save()
    }
    
}

extension SinglePickViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singlePickTableCell, for: indexPath)!
        
        let model = viewModel.models[indexPath.section].1[indexPath.row]
        
        cell.pickLabel.text = model.textRepresentation
        cell.selectionButton.isSelected = false
        if viewModel.pickedModels.contains(where: { $0.textRepresentation == model.textRepresentation }) {
            cell.selectionButton.isSelected = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.models[indexPath.section].1[indexPath.row]
        viewModel.picked(model: model)
        
        let cell = tableView.cellForRow(at: indexPath)! as! SinglePickTableCell
        cell.selectionButton.isSelected = !cell.selectionButton.isSelected
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: .init(x: 17, y: 10, width: 200, height: 18))
        label.text = viewModel.models[section].0
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = R.color.textBlackColor()
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}
