//
//  DeadlineView.swift
//  ToDo
//
//  Created by Arystan on 23.06.2023.
//

import UIKit

class DeadlineView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendar = CalendarView()
    
    private let hiddenDivider = DividerView()
    
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(switchControl)
        addSubview(hiddenDivider)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -17),
            
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            hiddenDivider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hiddenDivider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hiddenDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
            hiddenDivider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            hiddenDivider.isHidden = false
            addSubview(calendar)
            print("Switch is ON")
        } else {
            calendar.removeFromSuperview()
            hiddenDivider.isHidden = true
            print("Switch is OFF")
        }
    }
    
    
    
}
