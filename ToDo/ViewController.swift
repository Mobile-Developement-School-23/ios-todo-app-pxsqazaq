//
//  ViewController.swift
//  ToDo
//
//  Created by Arystan on 12.06.2023.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Example
        let json: [String: Any] = [
            "id": "1",
            "text": "Buy something",
            "importance": "важная",
            "deadline": 1623830400.0,
            "isDone": false,
            "createdDate": 1623772800.0
        ]
        
        let todoItem = ToDoItem.parse(json: json)
        
       print(todoItem)
    }
}

