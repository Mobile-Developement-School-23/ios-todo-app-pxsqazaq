//
//  TodoItem.swift
//  ToDo
//
//  Created by Arystan on 16.06.2023.
//

import Foundation


// MARK: - Struct of ToDoItem

struct ToDoItem {
    let id : String
    var text : String
    var importance : Importance
    var deadline : Date?
    var isDone : Bool
    let createdDate : Date
    let dateOfChange : Date?
    
    
    
    init(id: String = UUID().uuidString, text: String, importance: Importance = .normal, deadline: Date? = nil, isDone: Bool = false, createdDate: Date = Date(), dateOfChange: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdDate = createdDate
        self.dateOfChange = dateOfChange
        
    }
}

enum Importance : String {
    case low = "неважная"
    case normal = "обычная"
    case high = "важная"
}

// MARK: - JSON Parsing

extension ToDoItem {
    
    static func parse(json: Any) -> ToDoItem? {
        guard let dict = json as? [String: Any],
              let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let createdTimestamp = dict["createdDate"] as? Double
        else {
            return nil
        }
        
        let importanceRowValue = dict["importance"] as? String ?? ""
        let importance = Importance(rawValue : importanceRowValue) ?? .normal
        
        var deadline: Date?
        if let deadlineTimestamp = dict["deadline"] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        }
        
        let createdDate = Date(timeIntervalSince1970: createdTimestamp)
        
        var dateOfChange: Date?
        if let dateOfChangeTimestamp = dict["dateOfChange"] as? Double {
            dateOfChange = Date(timeIntervalSince1970: dateOfChangeTimestamp)
        }
        
        return ToDoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdDate: createdDate, dateOfChange: dateOfChange)
    }
    
    var json: [String: Any] {
        
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "createdDate": createdDate.timeIntervalSince1970
        ]
        
        if let deadline = deadline {
            dict["deadline"] = deadline.timeIntervalSince1970
        }
        
        if let dateOfChange = dateOfChange {
            dict["dateOfChange"] = dateOfChange.timeIntervalSince1970
        }
        
        if importance != .normal {
            dict["importance"] = importance.rawValue
        }
        
        return dict
    }
    
}

// MARK: - CSV Parsing

extension ToDoItem {
    static func stringToDate(from text: String) -> Date? {
        guard text != "" else { return nil }
        let timestamp = TimeInterval(Double(text) ?? Date().timeIntervalSince1970)
        return Date(timeIntervalSince1970: timestamp)
    }
    
    static func parse(csv : String) -> [ToDoItem] {
        var items: [ToDoItem] = []
        
        var rows = csv.components(separatedBy: "\n")
        rows.removeFirst()
        
        for row in rows {
            let components = row.components(separatedBy: ",")
            if components.count >= 6 {
                let id = components[0].trimmingCharacters(in: .whitespaces)
                let text = components[1].trimmingCharacters(in: .whitespaces)
                let importanceString = components[2].trimmingCharacters(in: .whitespaces)
                let deadlineString = components[3].trimmingCharacters(in: .whitespaces)
                let isDoneString = components[4].trimmingCharacters(in: .whitespaces)
                let creationDateString = components[5].trimmingCharacters(in: .whitespaces)
                let dateOfChangeString = components[6].trimmingCharacters(in: .whitespaces)

                
                if let isDone = Bool(isDoneString),
                   let createdDate = stringToDate(from: creationDateString){
                    let importance = Importance(rawValue: importanceString)
                    let deadline = stringToDate(from: deadlineString)
                    let item = ToDoItem(
                        id: id,
                        text: text,
                        importance: importance ?? .normal,
                        deadline: deadline,
                        isDone: isDone,
                        createdDate: createdDate,
                        dateOfChange: stringToDate(from: dateOfChangeString)
                    )
                    items.append(item)
                } else {
                    print("Failed to parse item with ID: \(id)")
                }
                
            }
        }
        return items
    }
    
    var csvString: String {
        var csv = "\(id),\(text),"
        let importance = importance.rawValue
        
        if importance == "обычная" {
            csv += ","
        }else{
            csv += "\(importance),"
        }
        
        if let deadline = deadline {
            csv += "\(deadline.timeIntervalSince1970),"
        } else {
            csv += ","
        }
        
        csv += "\(isDone),\(createdDate.timeIntervalSince1970)"
        
        if let dateOfChange = dateOfChange {
            csv += ",\(dateOfChange.timeIntervalSince1970)\n"
        }else{
            csv += ",\n"
        }
        
        return csv
    }
}
