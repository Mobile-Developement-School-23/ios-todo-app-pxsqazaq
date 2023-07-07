//
//  NetworkingService.swift
//  ToDo
//
//  Created by Arystan on 06.07.2023.
//

import Foundation
import CocoaLumberjack
import CocoaLumberjackSwift

protocol NetworkingService {
    func getItemList() async throws -> [ToDoItem]
    func getItem(by id: String) async throws -> ToDoItem
    func patchItemList(with toDoItems: [ToDoItem]) async throws -> [ToDoItem]
    func putElement(by id: String) async throws -> ToDoItem
    func postElement(with todoItemClient: ToDoItem) async throws -> ToDoItem
    func deleteElement(by id: String) async throws -> ToDoItem
}

class DefaultNetworkingService: NetworkingService {
    
    private let token = "pother"
    private let username = "Moldabek_A"
    private var revision = 6
    private let baseURL = "https://beta.mrdekk.ru/todobackend"
    private let endpoint = "/list"
    
    func getItemList() async throws -> [ToDoItem] {
        guard let url = createURL() else {
            throw NetworkingError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer pother", forHTTPHeaderField: "Autorization")
//        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        //        print("after")
        print(data)
        print(response)
        let list = try JSONDecoder().decode(ToDoListDTO.self, from: data)
        if let revision = list.revision {
            self.revision = revision
        }
        let todoItems = list.list.compactMap(mapData(element:))
        print(todoItems)
        DDLogInfo("GET list of ToDoItems from the server")
        print(todoItems)
        return todoItems
    }
    
    func getItem(by id: String) async throws -> ToDoItem {
        guard let url = createURL(id: id) else {
            throw NetworkingError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer pother", forHTTPHeaderField: "Autorization")
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItem = try parseTodoItem(data: data)
        print(todoItem)
        //        let response = try JSONDecoder().decode(TodoListDTO.self, from: data)
        //        if let revision = response.revision {
        //            self.revision = revision
        //        }
        DDLogInfo("GET element from the server")
        return todoItem
    }
    
    func putElement(by id: String) async throws -> ToDoItem {
        guard let url = createURL(id: id) else {
            throw NetworkingError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let toDoItem = try parseTodoItem(data: data)
        DDLogInfo("PUT element inside the server")
        return toDoItem
    }
    
    func postElement(with todoItemClient: ToDoItem) async throws -> ToDoItem {
        guard let url = createURL() else {
            throw NetworkingError.badURL
        }
        let element = todoItemClient.json
        //        print(element)
        let body = try JSONSerialization.data(withJSONObject: ["element": element])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        self.revision += 1
        request.addValue("Bearer pother", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        print("before")
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        print(data)
        let toDoItem = try parseTodoItem(data: data)
        print(toDoItem)
        DDLogInfo("POST element to the server")
        return toDoItem
    }
    
    func deleteElement(by id: String) async throws -> ToDoItem {
        guard let url = createURL(id: id) else {
            throw NetworkingError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        self.revision += 1
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let toDoItem = try parseTodoItem(data: data)
        DDLogInfo("DELETE element from server")
        return toDoItem
    }
    
    func patchItemList(with toDoItems: [ToDoItem]) async throws -> [ToDoItem] {
        guard let url = createURL() else {
            throw NetworkingError.badURL
        }
        let list = toDoItems.map({ $0.json })
        let body = try JSONSerialization.data(withJSONObject: ["list": list])
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = body
        let (data, _) =  try await URLSession.shared.dataTask(for: request)
        let toDoItems = try parseTodoItems(data: data)
        DDLogInfo("PATCH list of ToDoItems in the server")
        return toDoItems
    }
    
    private func createURL(id: String = "") -> URL? {
        let addressURL = baseURL + endpoint + id
        let url = URL(string: addressURL)
        return url
    }
    
    private func parseTodoItems(data: Data) throws -> [ToDoItem] {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let list = jsonArray["list"] as? [[String: Any]]
        else { throw NetworkingError.impossinbleToDecode }
        var todoItemsOrigin: [ToDoItem] = []
        for item in list {
            guard let todoItem = ToDoItem.parse(json: item)
            else { throw NetworkingError.impossinbleToDecode }
            todoItemsOrigin.append(todoItem)
        }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItemsOrigin
    }
    
    private func parseTodoItem(data: Data) throws -> ToDoItem {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let element = jsonArray["element"] as? [String: Any],
            let todoItem = ToDoItem.parse(json: element)
        else { throw URLError(.cannotDecodeContentData) }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItem
    }
    
    
    private func mapData(element: ToDoItemDTO) -> ToDoItem? {
        guard
            let id = element.id ,
            let importance = Importance(rawValue: element.importance)
        else {
            return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: TimeInterval(element.createdAt))
        let deadline = element.deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let modificationDate = Date(timeIntervalSince1970: TimeInterval(element.changedAt))
        
        return ToDoItem(
            id: id,
            text: element.text,
            importance: importance,
            deadline: deadline,
            isDone: element.isDone,
            createdDate: creationDate,
            dateOfChange: modificationDate
        )
    }
    
}

enum NetworkingError: Error {
    case requestFailed
    case badURL
    case impossinbleToDecode
}

enum HTTPMethod : String {
    case get  = "GET"
    case post = "POST"
    case put  = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
