//
//  ToDoItemDTO.swift
//  ToDo
//
//  Created by Arystan on 08.07.2023.
//

import Foundation
import UIKit

struct ToDoListDTO: Codable {
    let status: String?
    let list: [ToDoItemDTO]
    let revision: Int?

    init(status: String = "OK", list: [ToDoItemDTO], revision: Int) {
        self.status = status
        self.list = list
        self.revision = revision
    }

    enum CodingKeys: String, CodingKey {
        case status
        case list
        case revision
    }
}


struct ToDoItemIDDTO: Codable {
    let status: String?
    let element: ToDoItemDTO
    let revision: Int?

    init(status: String, element: ToDoItemDTO, revision: Int) {
        self.status = status
        self.element = element
        self.revision = revision
    }

    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
}

struct ToDoItemDTO: Codable {
    let id: String?
    let text: String
    let importance: String
    let deadline: Int?
    let isDone: Bool
    let createdAt: Int
    let changedAt: Int
    let color: String?
    let deviceId: String

    init(from toDoItem: ToDoItem) {
        self.id = toDoItem.id ?? UUID().uuidString
        self.text = toDoItem.text
        self.importance = toDoItem.importance.rawValue
        self.deadline = toDoItem.deadline.flatMap { Int($0.timeIntervalSince1970) }
        self.isDone = toDoItem.isDone
        self.createdAt = Int(toDoItem.createdDate.timeIntervalSince1970)
        self.changedAt = Int((toDoItem.dateOfChange ?? toDoItem.createdDate).timeIntervalSince1970)
        self.color = "ffff"
        self.deviceId = "ID"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isDone = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case color
        case deviceId = "last_updated_by"
    }
}
