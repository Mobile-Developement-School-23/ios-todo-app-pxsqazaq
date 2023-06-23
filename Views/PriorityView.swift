//
//  PriorityView.swift
//  ToDo
//
//  Created by Arystan on 23.06.2023.
//

import UIKit

class PriorityView: UIView {

    let titleLabel: UILabel = {
        let label =  UILabel()
        label.text = "Важность"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var segmentControl: UISegmentedControl = {
        let titles = ["low", "нет", "high"] as [Any]
        
        let segmentControl = UISegmentedControl(items: titles)
        segmentControl.setImage(UIImage(named: "low")?.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
        segmentControl.setImage(UIImage(named: "highicon")?.withRenderingMode(.alwaysOriginal), forSegmentAt: 2)
        segmentControl.selectedSegmentIndex = 1
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(segmentControl)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -17),
            
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
