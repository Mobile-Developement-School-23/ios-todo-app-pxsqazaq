//
//  DividerView.swift
//  ToDo
//
//  Created by Arystan on 23.06.2023.
//

import UIKit

final class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemGray5
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        nil
    }
}
