//
//  PriorityControl.swift
//  ToDo
//
//  Created by Arystan on 26.06.2023.
//

import UIKit

final class PriorityControl: UIControl {
    var isHiddenDivider = false {
        didSet {
            guard
                let dividerView,
                isHiddenDivider != oldValue
            else {
                return
            }
            
            dividerView.isHidden = isHiddenDivider
        }
    }

    private lazy var contentView = makeContentView()
    private lazy var dividerView = makeDivierView()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 48, height: 32)
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else {
                return
            }
            
            backgroundColor = isSelected ? DSColor.backElevated.color : .clear
        }
    }
    
    private(set) var priority: ToDoItem.Importance
    
    init(priority: ToDoItem.Importance) {
        self.priority = priority
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setup() {
        addSubview(contentView)
        if let dividerView {
            addSubview(dividerView)
        }
        
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        setupColors()
        setupConstraints()
    }
    
    private func setupColors() {
        backgroundColor = .clear
        if let dividerView {
            dividerView.backgroundColor = DSColor.supportSeparator.color
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
        if let dividerView {
            NSLayoutConstraint.activate(
                [
                    dividerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                    dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    dividerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                    dividerView.widthAnchor.constraint(equalToConstant: 0.25)
                ]
            )
        }
    }
    
    private func makeContentView() -> UIView {
        switch priority {
        case .low:
            let imageView = UIImageView(image: DSImage.priorityLow.image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        case .normal:
            let label = UILabel()
            label.font = DSFont.subhead.font
            label.textColor = DSColor.labelPrimary.color
            label.text = "нет" // TODO: - Localize
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        case .high:
            let imageView = UIImageView(image: DSImage.priorityHigh.image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }
    }
    
    private func makeDivierView() -> UIView? {
        guard priority != ToDoItem.Importance.allCases.last else {
            return nil
        }

        return DividerView()
    }
}
