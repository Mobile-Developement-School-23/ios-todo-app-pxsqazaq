//
//  UIViewControllerExtention.swift
//  ToDo
//
//  Created by Arystan on 26.06.2023.
//

import Foundation
import UIKit

extension UIViewController {
    func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideOfKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapOutsideOfKeyboard() {
        view.endEditing(true)
    }
}
