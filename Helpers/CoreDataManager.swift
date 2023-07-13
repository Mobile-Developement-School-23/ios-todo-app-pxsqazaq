//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Arystan on 13.07.2023.
//

import Foundation
import CoreData

struct CoreDataManager {

    private let coreDataStack: CoreDataStack

    init(modelName: String) {
        coreDataStack = CoreDataStack(modelName: modelName)
    }

    func save(_ item: ToDoItem) {
        let coreItem = CoreTodoItem(context: coreDataStack.managedContext)
        coreItem.id = item.id
        coreItem.text = item.text
        coreItem.priority = item.importance.rawValue
        coreItem.deadline = item.deadline
        coreItem.isCompleted = item.isDone
        coreItem.createdAt = item.createdDate
        coreItem.changedAt = item.dateOfChange

        coreDataStack.saveContext()
    }

    func fetch() -> [ToDoItem] {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")

        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)

        return coreItems?.map { coreItem in
            ToDoItem(
                id: coreItem.id!,
                text: coreItem.text!,
                importance : Importance(rawValue: coreItem.priority!) ?? .normal,
                deadline: coreItem.deadline,
                isDone: coreItem.isCompleted,
                createdDate: coreItem.createdAt!,
                dateOfChange: coreItem.changedAt
            )
        } ?? []
    }

    func update(_ item: ToDoItem) {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)

        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)

        guard let coreItem = coreItems?.first else { return }

        coreItem.text = item.text
        coreItem.priority = item.importance.rawValue
        coreItem.deadline = item.deadline
        coreItem.isCompleted = item.isDone
        coreItem.changedAt = item.dateOfChange

        coreDataStack.saveContext()
    }

    func delete(_ item: ToDoItem) {
        let fetchRequest = NSFetchRequest<CoreTodoItem>(entityName: "CoreTodoItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)

        let coreItems = try? coreDataStack.managedContext.fetch(fetchRequest)

        guard let coreItem = coreItems?.first else { return }

        coreDataStack.managedContext.delete(coreItem)
        coreDataStack.saveContext()
    }
}
