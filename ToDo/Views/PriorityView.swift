import UIKit

// MARK: - PriorityPickerViewDelegate

protocol PriorityPickerViewDelegate: AnyObject {
    func didSelectPriority(_ priority: ToDoItem.Importance)
}

// MARK: - PriorityPickerView

final class PriorityPickerView: UIView {
    weak var delegate: PriorityPickerViewDelegate?
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var prioritySegmentedControl = makePrioritySegmentedControl()
    private lazy var dividerView = DividerView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setup() {
        [
            titleLabel,
            prioritySegmentedControl,
            dividerView
        ].forEach { addSubview($0) }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setupColors()
        setupConstraints()
    }
    
    private func setupColors() {
        titleLabel.textColor = DSColor.labelPrimary.color
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ]
        )
        NSLayoutConstraint.activate(
            [
                prioritySegmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
                prioritySegmentedControl.leadingAnchor.constraint(
                    greaterThanOrEqualTo: titleLabel.trailingAnchor,
                    constant: 16
                ),
                prioritySegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
            ]
        )
        NSLayoutConstraint.activate(
            [
                dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                dividerView.heightAnchor.constraint(equalToConstant: 0.5)
            ]
        )
    }
    
    private func makePrioritySegmentedControl() -> UIView {
        let view = PrioritySegmentedControl()
        view.delegate = self
        return view
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = DSFont.body.font
        label.text = "Важность" // TODO: - Localize
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

// MARK: - PrioritySegmentedControlDelegate

extension PriorityPickerView: PrioritySegmentedControlDelegate {
    func didSelectPriority(_ priority: ToDoItem.Importance) {
        delegate?.didSelectPriority(priority)
    }
}
