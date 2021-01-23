//
//  RoomSettingsPremiumFeatureView.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 15.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxCocoa

struct RoomSettingsPremiumFeatureViewModel {
    let title: String
    let description: String
    let options: [(String, Bool)]
    let isEnabled: Bool
}

class RoomSettingsPremiumFeatureView: UIView {

    var viewModel: RoomSettingsViewModel! {
        didSet {
            
            let vm = viewModel.securitySettingsViewModel
            
            titleLabel.text = vm.title
            descriptionLabel.text = vm.description
            layer.borderColor = vm.isEnabled ? UIColor.clear.cgColor : R.color.textPinkColor()!.cgColor
            
            upgradeImageView.presenter = viewModel.router.owner
            upgradeImageView.defaultPage = .unlimitedRooms
            upgradeImageView.defaultPurchaseInterestContext = .unlimitedRooms
            
            setupOptions()
        }
    }

    private let titleLabel = UILabel(frame: .zero)
    private let descriptionLabel = UILabel(frame: .zero)
    private let upgradeImageView = SubscribeButton(frame: .zero)
    private let optionsStackView = UIStackView(frame: .zero)
    var switches: [UISwitch] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        configureLayout()
    }

    private func configure() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16.0
        layer.borderColor = R.color.textPinkColor()!.cgColor
        layer.borderWidth = 1.0

        optionsStackView.axis = .vertical
        optionsStackView.spacing = 0
        optionsStackView.distribution = .equalSpacing

        titleLabel.textColor = .fantasyBlack
        titleLabel.font = .boldFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear

        descriptionLabel.textColor = .basicGrey
        descriptionLabel.font = .regularFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear

    }

    private func configureLayout() {
        [titleLabel, descriptionLabel, upgradeImageView, optionsStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }

        NSLayoutConstraint.activate([
            upgradeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            upgradeImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: upgradeImageView.leftAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),

            optionsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            optionsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            optionsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }

    private func setupOptions() {
        optionsStackView.arrangedSubviews.forEach { optionsStackView.removeArrangedSubview($0) }
        switches = []
        viewModel.securitySettingsViewModel.options.forEach { option in
            let separatorView = UIView(frame: .zero)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .fantasySeparator

            let containerView = UIView(frame: .zero)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .white

            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .fantasyBlack
            label.font = .regularFont(ofSize: 15)
            label.text = option.0
            containerView.addSubview(label)

            let optionSwitch = UISwitch(frame: .zero)
            optionSwitch.translatesAutoresizingMaskIntoConstraints = false
            optionSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            optionSwitch.isOn = option.1
            optionSwitch.onTintColor = .fantasyPink
            switches.append(optionSwitch)
            containerView.addSubview(optionSwitch)

            NSLayoutConstraint.activate([
                separatorView.heightAnchor.constraint(equalToConstant: 1),
                containerView.heightAnchor.constraint(equalToConstant: 43),

                optionSwitch.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16),
                optionSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

                label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16),
                label.rightAnchor.constraint(equalTo: optionSwitch.leftAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])

            optionsStackView.addArrangedSubview(separatorView)
            optionsStackView.addArrangedSubview(containerView)
        }
        setNeedsLayout()
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        viewModel.setIsScreenShieldEnabled(sender.isOn) { 
            sender.isOn = false
        }
        
    }

}
