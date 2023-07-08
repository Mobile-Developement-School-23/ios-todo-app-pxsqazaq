//
//  Extentions.swift
//  ToDo
//
//  Created by Arystan on 27.06.2023.
//
import UIKit

extension UIViewController {
    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
}

