////
////  AddTaskViewController.swift
////  ToDo
////
////  Created by Arystan on 19.06.2023.
////
//
// import UIKit
// import SnapKit
//
// class AddTaskViewController: UIViewController, UITextViewDelegate {
//    
//    let initialHeight: CGFloat = 120
//    
//    lazy var remove: UIButton = {
//        let button = UIButton()
//        button.setTitle("Удалить", for: .normal)
//        button.titleLabel?.textAlignment = .center
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.backgroundColor = .white
//        button.setTitleColor(.red, for: .normal)
//        button.setTitleColor(.lightGray, for: .disabled)
//        button.layer.cornerRadius = 12
//        return button
//    }()
//    
//    lazy var textView: UITextView = {
//        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 500))
//        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 0, right: 0)
//        textView.font = UIFont.systemFont(ofSize: 18)
//        textView.layer.cornerRadius = 12
//        textView.backgroundColor = .white
//        textView.addPlaceholder(text: "Что надо сделать?")
//        textView.isScrollEnabled = false
//        textView.delegate = self
//        textView.sizeToFit()
//        return textView
//    }()
//    
//    lazy var textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: initialHeight)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationItem.title = "Дело"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: #selector(cancelButtonTapped))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
//        self.view.layer.backgroundColor = UIColor(red: 0.97, green: 0.966, blue: 0.951, alpha: 1).cgColor
//        
//        setupUI()
//        textViewHeightConstraint.isActive = true
//        textViewDidChange(textView)
//    }
//    
//    
//    @objc func cancelButtonTapped() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @objc func saveButtonTapped() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    private func setupUI() {
//        
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let contentView = UIView()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        
//        let priorityView = PriorityView()
//        
//        let deadlineView = DeadlineView()
//        
//        let divider = DividerView()
//        
//        
//        let stackView = UIStackView(arrangedSubviews: [priorityView, divider, deadlineView])
//        stackView.axis = .vertical
//        stackView.layer.cornerRadius = 16
//        stackView.backgroundColor = .white
//        
//        
//        
//        
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        contentView.addSubview(textView)
//        contentView.addSubview(stackView)
//        contentView.addSubview(remove)
//        
//        
//        
//        scrollView.snp.makeConstraints {
//            $0.edges.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        contentView.snp.makeConstraints {
//            $0.edges.equalTo(scrollView)
//            $0.width.equalTo(scrollView)
//        }
//        
//        textView.snp.makeConstraints {
//            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(33)
//            $0.left.equalToSuperview().offset(16)
//            $0.right.equalToSuperview().inset(16)
//        }
//        
//        divider.snp.makeConstraints {
//            $0.height.equalTo(0.5)
//            $0.left.equalToSuperview().offset(16)
//            $0.right.equalToSuperview().offset(-16)
//        }
//        
//        stackView.snp.makeConstraints {
//            $0.top.equalTo(textView.snp.bottom).offset(16)
//            $0.left.equalToSuperview().offset(16)
//            $0.right.equalToSuperview().offset(-16)
//        }
//        
//        remove.snp.makeConstraints {
//            $0.height.equalTo(56)
//            $0.top.equalTo(deadlineView.snp.bottom).offset(16)
//            $0.left.equalToSuperview().offset(16)
//            $0.right.equalToSuperview().inset(16)
//            $0.bottom.equalToSuperview().inset(16)
//        }
//    }
//    
//    
//    func textViewDidChange(_ textView: UITextView) {
//        let contentSize = textView.sizeThatFits(textView.bounds.size)
//        let minHeight: CGFloat = 120
//        
//        textViewHeightConstraint.constant = max(contentSize.height, minHeight)
//        
//        let isTextViewEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//        navigationItem.rightBarButtonItem?.isEnabled = !isTextViewEmpty
//        remove.isEnabled = !isTextViewEmpty
//        
//        
//        UIView.animate(withDuration: 0.3) {
//            self.view.layoutIfNeeded()
//        }
//    }
// }
//
//
//
// extension UITextView {
//    func addPlaceholder(text: String) {
//        let placeholderLabel = UILabel()
//        placeholderLabel.text = text
//        placeholderLabel.font = self.font
//        placeholderLabel.sizeToFit()
//        placeholderLabel.textColor = UIColor.lightGray
//        placeholderLabel.tag = 999
//        placeholderLabel.isHidden = !self.text.isEmpty
//        
//        self.addSubview(placeholderLabel)
//        self.resizePlaceholderLabel(placeholderLabel: placeholderLabel)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
//    }
//    
//    func resizePlaceholderLabel(placeholderLabel: UILabel) {
//        let x = self.textContainer.lineFragmentPadding + self.textContainerInset.left
//        let y = self.textContainerInset.top
//        let width = self.frame.width - (x + self.textContainer.lineFragmentPadding + self.textContainerInset.right)
//        let height = placeholderLabel.frame.height
//        
//        placeholderLabel.frame = CGRect(x: x, y: y, width: width, height: height)
//    }
//        
//    @objc private func textChanged() {
//        if let placeholderLabel = self.viewWithTag(999) as? UILabel {
//            placeholderLabel.isHidden = !self.text.isEmpty
//        }
//    }
// }
//
//
//
