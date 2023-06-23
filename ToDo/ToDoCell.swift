//
//  ToDoCell.swift
//  ToDo
//
//  Created by Arystan on 18.06.2023.
//

import UIKit
import SnapKit

class ToDoCell: UITableViewCell {
    
    static let identifier = "ToDoCell"
    
    private var isDone: Bool = false
    private var importance: String = ""
    
    private var toDoText : UILabel = {
        let text = UILabel()
        text.numberOfLines = 3
        text.textColor = .black
        text.lineBreakMode = .byTruncatingTail
        text.font = UIFont.systemFont(ofSize: 17)
        return text
    }()
    
    private var deadline : UILabel = {
        let deadline = UILabel()
        deadline.text = "31 July"
        deadline.textColor = .lightGray
        deadline.font = UIFont.systemFont(ofSize: 15)
        return deadline
    }()
    
    private let calendarIcon : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Calendar")
        return image
    }()
    
    private let chevronIcon : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Chevron")
        return image
    }()
    
    private let priorityIcon : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    private let isDoneIcon : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "notDone")
        return imageView
    }()
    lazy var stackView : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [isDoneIcon, priorityIcon])
        stack.spacing = 15
        stack.axis = .horizontal
        return stack
    }()
    
    
    lazy var stackViewDeadline : UIStackView = {
        let stackViewDeadline = UIStackView(arrangedSubviews: [calendarIcon, deadline])
        stackViewDeadline.axis = .horizontal
        stackViewDeadline.spacing = 4
        return stackViewDeadline
    }()
    
    
    private func setupUI() {
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(chevronIcon)
        self.contentView.addSubview(deadline)
        
        
        
        chevronIcon.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(7)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.height.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        isDoneIcon.snp.makeConstraints {
            $0.height.width.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        priorityIcon.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.width.equalTo(10)
        }
        
        calendarIcon.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        
    }
    
    lazy var stackTask: UIStackView = {
        let stackTask = UIStackView()
        stackTask.axis = .vertical
        return stackTask
    }()
    func withDeadline(deadline: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        self.deadline.text = dateFormatter.string(from: deadline)
        self.contentView.addSubview(stackTask)
        stackTask.addArrangedSubview(toDoText)
        stackTask.addArrangedSubview(stackViewDeadline)
        stackTask.snp.makeConstraints {
            $0.left.equalTo(stackView.snp.right).offset(5)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-39)
            $0.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    func withoutDeadline() {
        stackTask.removeFromSuperview()
        toDoText.removeFromSuperview()
        self.contentView.addSubview(toDoText)
        toDoText.snp.makeConstraints {
            $0.left.equalTo(stackView.snp.right).offset(5)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(16)
            $0.right.equalToSuperview().offset(-39)
        }
        toDoText.numberOfLines = 3
           toDoText.lineBreakMode = .byTruncatingTail
    }
    
    func donetext(label: UILabel) {
        self.priorityIcon.isHidden = true
        isDoneIcon.image = UIImage(named: "done")
        label.textColor = .lightGray
    }

    func prioritytext(label: UILabel) {
        label.textColor = .black
        isDoneIcon.image = UIImage(named: "priority")
        priorityIcon.image = UIImage(named: "highicon")
        self.priorityIcon.isHidden = false

    }

    func lowtext(label: UILabel) {
        label.textColor = .black
        self.isDoneIcon.image = UIImage(named: "notDone")
        self.priorityIcon.image = UIImage(named: "low")
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
                self.isDoneIcon.image = UIImage(named: "notDone")
                self.toDoText.textColor = .black
                self.priorityIcon.isHidden = true
                
            }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

