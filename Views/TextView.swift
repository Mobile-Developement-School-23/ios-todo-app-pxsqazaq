////
////  TextView.swift
////  ToDo
////
////  Created by Arystan on 23.06.2023.
////
//
//import Foundation
//import UIKit
//
//
//class TextView: UIView, UITextViewDelegate {
//    
//    private let initialHeight: CGFloat = 120
//    
//    private lazy var textView: UITextView = {
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
//    
//     lazy var textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: initialHeight)
//    
//    
//     func textViewDidChange() {
//        let contentSize = textView.sizeThatFits(textView.bounds.size)
//         
//        textViewHeightConstraint.constant = max(contentSize.height, initialHeight)
//    }
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubviews()
//        
//    }
//    
//    private func addConstraints() {
//        NSLayoutConstraint.activate([
//            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            textView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//        ])
//    }
//    
//    private func addSubviews() {
//        addSubview(textView)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension UITextView {
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
//}
