//
//  SubView.swift
//  ToDo
//
//  Created by Arystan on 26.06.2023.
//

import Foundation
import UIKit

// MARK: - TodoItemDetailsViewDelegate

protocol TodoItemDetailsViewDelegate: AnyObject {
    func didSelectPriority(_ priority: ToDoItem.Importance)
    func didSelectDeadline(_ date: Date?)
}

// MARK: - TodoItemDetailsView

final class TodoItemDetailsView: UIView {
    weak var delegate: TodoItemDetailsViewDelegate?
    
    private lazy var stackView = makeStackView()
    private lazy var priorityView = makePriorityView()
    private lazy var deadlineControl = makeDeadlineSwitchControl()
    private lazy var calendarView = makeCalendarView()
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }
    
    private var deadlineFallback: Date {
        return CalendarProvider.calendar.date(
            byAdding: .day,
            value: 1,
            to: Date()
        ) ?? Date()
    }
    
    private var colorFallback: UIColor {
        return DSColor.colorBlue.color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    @objc
    private func didTapDeadlineControl(_ sender: SwitchControl) {
        sender.isSelected.toggle()
        deadlineControl.subtitle = sender.isSelected ? dateFormatter.string(from: deadlineFallback) : nil
        calendarView.selectedDate = sender.isSelected ? deadlineFallback : nil
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.calendarView.isHidden = !sender.isSelected
        }
        
        delegate?.didSelectDeadline(sender.isSelected ? deadlineFallback : nil)
    }
    
    private func setup() {
        addSubview(stackView)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        
        setupColors()
        setupConstraints()
    }
    
    private func setupColors() {
        backgroundColor = DSColor.backSecondary.color
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews: [
                priorityView,
                deadlineControl,
                calendarView,
            ]
        )
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makePriorityView() -> UIView {
        let view = PriorityPickerView()
        view.delegate = self
        return view
    }
    
    private func makeDeadlineSwitchControl() -> SwitchControl {
        let control = SwitchControl()
        control.addTarget(self, action: #selector(didTapDeadlineControl), for: .touchUpInside)
        control.isHiddenDividerByDefault = false
        control.title = "Сделать до" // TODO: - Localize
        return control
    }
    
    private func makeCalendarView() -> CalendarView {
        let view = CalendarView()
        view.delegate = self
        view.isHidden = true
        return view
    }
}

// MARK: - PriorityPickerViewDelegate

extension TodoItemDetailsView: PriorityPickerViewDelegate {
    func didSelectPriority(_ priority: ToDoItem.Importance) {
        delegate?.didSelectPriority(priority)
    }
}

// MARK: - CalendarViewDelegate

extension TodoItemDetailsView: CalendarViewDelegate {
    func calendarView(_ view: CalendarView, didChange date: Date) {
        deadlineControl.subtitle = dateFormatter.string(from: date)
        delegate?.didSelectDeadline(date)
    }
}


