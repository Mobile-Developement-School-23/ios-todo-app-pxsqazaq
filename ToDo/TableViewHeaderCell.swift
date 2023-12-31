////
////  TableViewHeaderCell.swift
////  ToDo
////
////  Created by Arystan on 01.07.2023.
////
//
// import Foundation
// import UIKit
//
// class TableViewHeaderCell: UITableViewHeaderFooterView {
//
//    var valueDidChange: (() -> Void)?
//
//    static let identifier: String = "TableViewHeaderCell"
//
//    var textView = UILabel()
//    let buttonView = UIButton()
//
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupViews(){
//        setupText()
//        setupButton()
//        setupContentView()
//        setupContents()
//    }
//
//    func setupText(){
//
//        textView.textColor = Colors.labelTertiary.color
//        textView.text = "Выполнено - \(rootViewModel.file.todoItems.filter( {$0.isDone} ).count)"
//    }
//
//    func setupButton(){
//        buttonView.setTitle("Показать", for: .normal)
//        buttonView.setTitle("Скрыть", for: .selected)
//        buttonView.setTitleColor(.systemBlue, for: .normal)
//        buttonView.addTarget(self, action: #selector(pressedButtonHeader), for: .touchUpInside)
//    }
//
//    func setupContentView(){
//        contentView.backgroundColor = Colors.backPrimary.color
//        contentView.addSubview(textView)
//        contentView.addSubview(buttonView)
//    }
//
//    func setupContents() {
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        buttonView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//
//            buttonView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
//            buttonView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            buttonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        ])
//    }
// }
//
// extension TableViewHeaderCell {
//
//    @objc func pressedButtonHeader(_ button: UIButton) {
//        if button.isSelected {
//            rootViewModel.changePresentationStatus(to: Status.ShowUncompleted)
//            buttonView.isSelected = false
//            self.valueDidChange?()
//
//        } else {
//            rootViewModel.changePresentationStatus(to: Status.ShowAll)
//            buttonView.isSelected = true
//            self.valueDidChange?()
//        }
//    }
// }
//
