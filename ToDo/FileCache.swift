//
//  FileCache.swift
//  ToDo
//
//  Created by Arystan on 16.06.2023.
//

import Foundation


enum FileCacheError: Error {
    case notFound
    case notSupported
    case failedToRead
    case failedToWrite
}
// MARK: - FileCache realization

final class FileCache {
    private (set) var todoItems : [ToDoItem] = []
    private var filepath : String
    
    init(filepath: String) {
        self.filepath = filepath
        todoItems = []
    }
    
    func add(todoItem: ToDoItem) {
        guard !todoItems.contains(where: {$0.id == todoItem.id}) else {
            print("Todo item with ID '\(String(describing: todoItem.id))' already exists. Duplicate item not added.")
            return
        }
        todoItems.append(todoItem)
    }
    
    func update(id: String, text: String, importance: Importance, deadline: Date?) {
        guard let index = todoItems.firstIndex(where: { $0.id == id }) else { return }
        todoItems[index].text = text
        todoItems[index].importance = importance
        todoItems[index].deadline = deadline
    }
    
    func remove(id: String) {
        guard let index  = todoItems.firstIndex(where: { $0.id == id }) else {
            print("Todo item with ID '\(id)' not found. Removal failed.")
            return
        }
        todoItems.remove(at: index)
    }
    
    func saveToJSONFile() {
        let json = todoItems.map{$0.json}
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            print("Failed to serialize todo items to JSON")
            return
        }
        
        do {
            try jsonData.write(to: URL(fileURLWithPath: filepath))
            print("Todo items saved to file")
        }catch { 
            print("Failed to save todo items to file. Error: \(error)")
        }
    }
    
    func loadFromJSONFile() {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: filepath) {
            fileManager.createFile(atPath: filepath, contents: nil, attributes: nil)
            print("New file created at \(filepath)")
        }
        
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filepath)) else {
            print("No existing file found at \(filepath)")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            guard let jsonArray = json as? [[String:Any]] else {
                print("Invalid JSON format")
                return
            }
            
            let loadedItems = jsonArray.compactMap { ToDoItem.parse(json: $0) }
            todoItems = loadedItems
            print("Todo items loaded from file")
        }catch {
            print("Failed to load todo items from file. Error: \(error)")
        }
    }
    
    func completedTask(id: String) {
        guard let index = todoItems.firstIndex(where: { $0.id == id }) else { return }
        todoItems[index].isDone = true
    }
    
    func notCompleteTask(id: String) {
        guard let index = todoItems.firstIndex(where: { $0.id == id }) else { return }
        todoItems[index].isDone = false
    }
}




// MARK: - FileCache (CSV Part)

extension FileCache {
    func saveToCSVFile() {
        var csvString = "ID,Text,Importance,Deadline,IsCompleted,CreationDate,DateOfChange\n"
        
        for item in todoItems {
            csvString += item.csvString
        }
        
        do {
            try csvString.write(to: URL(fileURLWithPath: filepath), atomically: true, encoding: .utf8)
            print("CSV file saved successfully.")
        }catch {
            print("Failed to save CSV file: \(error)")
        }
    }
    
    
    func loadFromCSVFile() {
        do {
            guard let csvString = try? String(contentsOf: URL(fileURLWithPath: filepath)) else{
                print("No existing file found at \(filepath)")
                return
            }
            todoItems = ToDoItem.parse(csv: csvString)
        }
    }
}
