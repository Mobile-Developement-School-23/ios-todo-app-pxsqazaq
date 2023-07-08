//
//  AddTodoPresentationModel.swift
//  ToDo
//
//  Created by Arystan on 27.06.2023.
//

import Foundation

struct AddTodoPresentationModel {
    
    var id: String?
    var text: String?
    var importance: Importance = .normal
    var dueDate: Date?
    
    init(from todoItem: ToDoItem) {
        id = todoItem.id
        text = todoItem.text
        importance = todoItem.importance
        dueDate = todoItem.deadline
    }
    
    init(textInput: String = "") {
        text = textInput
    }
}
