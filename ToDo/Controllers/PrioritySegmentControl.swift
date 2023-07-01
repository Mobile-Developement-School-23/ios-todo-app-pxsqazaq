//
//  PrioritySegmentControl.swift
//  ToDo
//
//  Created by Arystan on 26.06.2023.
//

import UIKit

// MARK: - PrioritySegmentedControlDelegate

protocol PrioritySegmentedControlDelegate: AnyObject {
    func didSelectPriority(_ priority: ToDoItem.Importance)
}

// MARK: - PrioritySegmentedControl

final class PrioritySegmentedControl: UIView {
    weak var delegate: PrioritySegmentedControlDelegate?
    
    private lazy var stackView = makeStackView()
    
    private lazy var controls = ToDoItem.Importance.allCases.map {
        let control = PriorityControl(priority: $0)
        control.addTarget(self, action: #selector(didTapControl), for: .touchUpInside)
        return control
    }
    
    var selectedPriority: ToDoItem.Importance = .normal {
        didSet {
            guard selectedPriority != oldValue else {
                return
            }

            configureControls()
            delegate?.didSelectPriority(selectedPriority)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    @objc
    private func didTapControl(_ sender: PriorityControl) {
        selectedPriority = sender.priority
    }
    
    private func setup() {
        
        addSubview(stackView)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        
        configureControls()
        setupColors()
        setupConstraints()
    }
    
    private func configureControls() {
        controls.forEach {
            $0.isHiddenDivider = false
        }
        
        controls.forEach {
            $0.isSelected = ($0.priority == selectedPriority)
            $0.isHiddenDivider = ($0.priority == selectedPriority)
        }
        
        guard
            let index = ToDoItem.Importance.allCases.firstIndex(of: selectedPriority),
            index > 0
        else {
            return
        }
        
        controls[index - 1].isHiddenDivider = true
    }
    
    private func setupColors() {
        backgroundColor = DSColor.supportOverlay.color
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
            ]
        )
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: controls)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
