//
//  EditRelationshipViewController.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class EditRelationshipViewController: UIViewController {
    
    func setUp(viewModel: EditRelationshipViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addFantasyGradient()
        title = R.string.localizable.editRelationshipTitle()
        
        navigationItem.leftBarButtonItem = .init(image: R.image.back()!, style: .plain, target: self, action: #selector(back))

        if let describePartnerTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.describePartnerTableViewCell, for: IndexPath(row: 0, section: 1)) {
            self.describePartnerTableViewCell = describePartnerTableViewCell
        }
        
        viewModel.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.partnerGenderError
            .map { !$0 }
            .drive(describePartnerTableViewCell.partnerGenderErrorView.rx.isHidden)
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - Private
    
    private var viewModel: EditRelationshipViewModel!
    
    @IBOutlet private weak var tableView: UITableView!
    private var describePartnerTableViewCell: DescribePartnerTableViewCell!
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, EditRelationshipViewModel.Row>>(
        configureCell: { [unowned self] (_, tableView, indexPath, model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.radioOptionTableViewCell, for: indexPath)!
            
            switch model {
            case .relationshipType(let relationshipType, let isSelected):
                cell.titleLabel.text = relationshipType.pretty
                cell.tickButton.isSelected = isSelected
                cell.tickButton.tag = indexPath.row
                
                cell.tickButton.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.tickButton.addTarget(self, action: #selector(self.selectRelationshipType(_:)), for: .touchUpInside)
            case .partnerGender(let gender, let isSelected):
                cell.titleLabel.text = gender.pretty
                cell.tickButton.isSelected = isSelected
                cell.tickButton.tag = indexPath.row
                
                cell.tickButton.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.tickButton.addTarget(self, action: #selector(self.selectPartnerGender(_:)), for: .touchUpInside)
            }
                
            return cell
        }
    )
}

private extension EditRelationshipViewController {
    
    @IBAction private func selectRelationshipType(_ sender: TickButton) {
        viewModel.selectRelationshipType(index: sender.tag)
    }
    
    @IBAction private func selectPartnerGender(_ sender: TickButton) {
        viewModel.selectPartnerGender(index: sender.tag)
    }
    
    @objc private func back() {
        viewModel.back()
    }
}

extension EditRelationshipViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? UIView() : describePartnerTableViewCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            viewModel.selectRelationshipType(index: indexPath.row)
        } else if indexPath.section == 1 {
            viewModel.selectPartnerGender(index: indexPath.row)
        }
    }
}
