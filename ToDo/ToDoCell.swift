//
//  ToDoCell.swift
//  ToDo
//
//  Created by Arystan on 18.06.2023.
//

import UIKit
import SnapKit

protocol ToDoCellDelegate: AnyObject {
    func radioButtonTapped(cell: ToDoCell)
}


class ToDoCell: UITableViewCell {

    weak var delegate: ToDoCellDelegate?
    static let identifier = "ToDoCell"
    private var isDone: Bool = false
    private var importance: String = ""
    
    private var toDoText : UILabel = {
        let text = UILabel()
        text.numberOfLines = 3
        text.textColor = Colors.labelPrimary.color
        text.lineBreakMode = .byTruncatingTail
        text.font = GlobalConstants.body
        return text
    }()
    
    private var deadline : UILabel = {
        let deadline = UILabel()
        deadline.textColor = Colors.labelTertiary.color
        deadline.font = GlobalConstants.subhead
        return deadline
    }()
    
    private let calendarIcon : UIImageView = {
        let image = UIImageView()
        image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        image.image = UIImage(named: "Calendar")
        return image
    }()
    
    private let chevronIcon : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "present")
        return image
    }()
    
    private let priorityIcon : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return image
    }()
    
    private let radioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "done"), for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var stackViewItem : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priorityIcon, toDoText])
        stack.spacing = 5
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var stackViewDeadline : UIStackView = {
        let stackViewDeadline = UIStackView(arrangedSubviews: [calendarIcon, deadline])
        stackViewDeadline.axis = .horizontal
        stackViewDeadline.spacing = 4
        return stackViewDeadline
    }()
    
    lazy var stackAll: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stackViewItem, stackViewDeadline])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    override func prepareForReuse() {
        toDoText.attributedText = nil
        toDoText.textColor = Colors.labelPrimary.color
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(radioButton)
        self.contentView.addSubview(stackAll)
        self.contentView.addSubview(chevronIcon)
        
        radioButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
        }
        
        chevronIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-16)
        }
        
        stackAll.snp.makeConstraints {
            $0.left.equalTo(radioButton.snp.right).offset(12)
            $0.top.bottom.equalToSuperview().inset(16)
            $0.right.equalToSuperview().offset(-39)
        }
    }
    
    func withDeadline(deadline: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        self.deadline.text = dateFormatter.string(from: deadline)
        stackViewDeadline.isHidden = false
    }
    
    func withoutDeadline() {
        stackViewDeadline.isHidden = true
    }
    
    private func makeStrikeThrough(label: UILabel) {
        let attributedString = NSAttributedString(string: label.text ?? "", attributes: [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ])
        label.attributedText = attributedString
    }
    
    func donetext(label: UILabel) {
        self.priorityIcon.isHidden = true
        radioButton.setImage(UIImage(named: "done"), for: .normal)
        makeStrikeThrough(label: label)
        label.textColor = .lightGray
    }
    
    func prioritytext(label: UILabel) {
        radioButton.setImage(UIImage(named: "priority"), for: .normal)
        priorityIcon.image = UIImage(named: "highicon")
        self.priorityIcon.isHidden = false
        
    }
    
    func lowtext(label: UILabel) {
        radioButton.setImage(UIImage(named: "Ellipse 1"), for: .normal)
        self.priorityIcon.image = UIImage(named: "low2")
        self.priorityIcon.isHidden = false
    }
    
    func configure(with viewModel: ToDoItem) {
        self.toDoText.text = viewModel.text
        self.isDone = viewModel.isDone
        self.importance = viewModel.importance.rawValue
        if(viewModel.deadline != nil){
            withDeadline(deadline: viewModel.deadline!)
        }
        else{
            withoutDeadline()
        }
        if self.isDone {
            donetext(label: self.toDoText)
        } else if self.importance == "важная" {
            prioritytext(label: self.toDoText)
        } else if self.importance == "неважная"{
            lowtext(label: self.toDoText)
        }
        else {
            radioButton.setImage(UIImage(named: "Ellipse 1"), for: .normal)
            self.priorityIcon.isHidden = true
        }
    }
    
    @objc private func radioButtonTapped() {
        delegate?.radioButtonTapped(cell: self)
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

