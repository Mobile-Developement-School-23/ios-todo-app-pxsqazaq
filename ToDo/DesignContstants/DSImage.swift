//
//  DSImage.swift
//  ToDo
//
//  Created by Arystan on 26.06.2023.
//

import UIKit

enum DSImage {
    case plusCircle
    case radioButtonHighPriority
    case radioButtonOff
    case radioButtonOn
    case add
    case calendar
    case chevron
    case priorityHigh
    case priorityLow
    case showOff
    case showOn
}

extension DSImage {
    var image: UIImage {
        var image: UIImage?
        
        switch self {
        case .plusCircle:
            image = UIImage(named: "plus_circle_24x24")
        case .radioButtonHighPriority:
            image = UIImage(named: "radio_button_high_priority_24x24")
        case .radioButtonOff:
            image = UIImage(named: "radio_button_off_24x24")
        case .radioButtonOn:
            image = UIImage(named: "radio_button_on_24x24")
        case .add:
            image = UIImage(named: "add")
        case .calendar:
            image = UIImage(named: "calendar")
        case .chevron:
            image = UIImage(named: "chevron")
        case .priorityHigh:
            image = UIImage(named: "priority_high")
        case .priorityLow:
            image = UIImage(named: "priority_low")
        case .showOff:
            image = UIImage(named: "show_off")
        case .showOn:
            image = UIImage(named: "show_on")
        }
        
        return image ?? UIImage()
    }
}
