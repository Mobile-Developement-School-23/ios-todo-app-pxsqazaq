//
//  SQLiteManager.swift
//  ToDo
//
//  Created by Arystan on 12.07.2023.
//

import Foundation
import SQLite

final class SQLiteManager {
    static let shared = SQLiteManager()
    
    private let connection: Connection?
    
    let table = Table("todo_items")
    let id = Expression<String>("id")
    let text = Expression<String>("text")
    let importance = Expression<String>("importance")
    let deadline = Expression<Date?>("deadline")
    let isDone = Expression<Bool>("is_done")
    let createdDate = Expression<Date>("created_date")
    let dateOfChange = Expression<Date?>("date_of_change")
    
    private init() {
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("ToDoItems.sqlite").appendingPathExtension("sqlite3")
            
            self.connection = try Connection(fileURL.path)
        } catch {
            print(error)
            self.connection = nil
        }
    }
    
    func createTable() {
        do {
            try connection?.run(table.create(ifNotExists: true) { table in
                table.column(self.id, primaryKey: true)
                table.column(self.text)
                table.column(self.importance)
                table.column(self.deadline)
                table.column(self.isDone)
                table.column(self.createdDate)
                table.column(self.dateOfChange)
            })
            print("Created table")
        } catch {
            print("Failed to create table: \(error)")
        }
    }
    
    func insert(todoItem: ToDoItem) {
        
        do {
            try self.connection?.transaction {
                let insert = table.insert(self.id <- todoItem.id,
                                          self.text <- todoItem.text,
                                          self.importance <- todoItem.importance.rawValue,
                                          self.deadline <- todoItem.deadline,
                                          self.isDone <- todoItem.isDone,
                                          self.createdDate <- todoItem.createdDate,
                                          self.dateOfChange <- todoItem.dateOfChange)
                try self.connection?.run(insert)
            }
            
//            print("Todo items saved to SQLite database")
        } catch {
            print("Failed to save todo items to SQLite database: \(error)")
        }
    }
    
    func update(updatedItem: ToDoItem) {
        let item = self.table.filter(self.id == updatedItem.id)
        let updateItem = item.update(self.text <- updatedItem.text, self.importance <- updatedItem.importance.rawValue, self.deadline <- updatedItem.deadline, self.isDone <- updatedItem.isDone)
        do {
            try self.connection?.run(updateItem)
        } catch {
            print(error)
        }
    }
    
    func delete(id: String) {
        let item = self.table.filter(self.id == id)
        let deleteItem = item.delete()
        do {
            try self.connection?.run(deleteItem)
//            print("Deleted")
        } catch {
            print(error)
        }
    }
    
    func load() -> [ToDoItem] {
        
        var loadedItems: [ToDoItem] = []
        
        do {
            for row in try self.connection!.prepare(table) {
                let item = ToDoItem(id: row[id],
                                    text: row[text],
                                    importance: Importance(rawValue: row[importance]) ?? .normal,
                                    deadline: row[deadline],
                                    isDone: row[isDone],
                                    createdDate: row[createdDate],
                                    dateOfChange: row[dateOfChange])
                loadedItems.append(item)
            }
            
            print("Todo items loaded from SQLite database")
        } catch {
            print("Failed to load todo items from SQLite database: \(error)")
        }
        
        return loadedItems
    }
}
