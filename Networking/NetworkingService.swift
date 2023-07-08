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
    func getItem(by id: String) async throws -> ToDoItem?
    func patchItemList(with toDoItems: [ToDoItem]) async throws -> [ToDoItem]
    func putElement(by item: ToDoItem) async throws -> ToDoItem?
    func postElement(with todoItemClient: ToDoItem) async throws -> ToDoItem?
    func deleteElement(by id: String) async throws -> ToDoItem?
}

final class DefaultNetworkingService: NetworkingService {
    
    private struct Configuration {
        static let scheme = "https"
        static let host = "beta.mrdekk.ru"
        static let path = "todobackend"
        static let token = "pother"
    }
    
    private(set) var numberOfTasks = 0
    private let urlSession: URLSession
    private var revision: Int = 0
    private let deviceID: String
    
    init(urlSession: URLSession = URLSession.shared, deviceID: String) {
        self.urlSession = urlSession
        self.deviceID = deviceID
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func incrementNumberOfTasks() {
        numberOfTasks += 1
    }
    
    @MainActor
    func decrementNumberOfTasks() {
        numberOfTasks -= 1
    }
    
    func getItemList() async throws -> [ToDoItem] {
        let request = try makeGetRequest(path: "/\(Configuration.path)/list")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoListDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(mapData(element:))
    }
    
    func patchItemList(with todoList: [ToDoItem]) async throws -> [ToDoItem] {
        let todoListDTO = TodoListDTO(list: todoList.map { mapData(todoItem: $0) })
        let requestBody = try JSONEncoder().encode(todoListDTO)
        let request = try makePatchRequest(path: "/\(Configuration.path)/list", body: requestBody)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoListDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(mapData(element:))
    }
    
    func getItem(by id: String) async throws -> ToDoItem? {
        let request = try makeGetRequest(path: "/\(Configuration.path)/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }
    
    @discardableResult
    func postElement(with todoItem: ToDoItem) async throws -> ToDoItem? {
        let todoItemDTO = TodoItemDTO(element: mapData(todoItem: todoItem))
        print(todoItemDTO)
        let requestBody = try JSONEncoder().encode(todoItemDTO)
        let request = try makePostRequest(path: "/\(Configuration.path)/list", body: requestBody)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }
    
    @discardableResult
    func putElement(by todoItem: ToDoItem) async throws -> ToDoItem? {
        let todoItemDTO = TodoItemDTO(element: mapData(todoItem: todoItem))
        print(todoItemDTO)
        let requestBody = try JSONEncoder().encode(todoItemDTO)
        let request = try makePutRequest(
            path: "/\(Configuration.path)/list/\(todoItem.id)",
            body: requestBody
        )
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }
    
    @discardableResult
    func deleteElement(by id: String) async throws -> ToDoItem? {
        let request = try makeDeleteRequest(path: "/\(Configuration.path)/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        
        return mapData(element: response.element)
    }
    
    // MARK: - Private Methods
    
    private func makeURL(path: String) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Configuration.scheme
        urlComponents.host = Configuration.host
        urlComponents.path = path
        
        guard let url = urlComponents.url else {
            throw RequestError.wrongURL(urlComponents)
        }
        return url
    }
    
    private func makeGetRequest(path: String) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("20", forHTTPHeaderField: "X-Generate-Fails") // generate fails
        return request
    }
    
    private func makePatchRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("20", forHTTPHeaderField: "X-Generate-Fails") // generate fails
        request.httpBody = body
        return request
    }
    
    private func makePostRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("20", forHTTPHeaderField: "X-Generate-Fails") // generate fails
        request.httpBody = body
        return request
    }
    
    private func makePutRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("20", forHTTPHeaderField: "X-Generate-Fails") // generate fails
        request.httpBody = body
        return request
    }
    
    private func makeDeleteRequest(path: String) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("20", forHTTPHeaderField: "X-Generate-Fails") // generate fails
        return request
    }
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await urlSession.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.unexpectedResponse
        }
        try handleStatusCode(response: response)
        return (data, response)
    }
    
    private func handleStatusCode(response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 100 ... 299:
            return
        case 400:
            throw RequestError.badRequest
        case 401:
            throw RequestError.wrongAuth
        case 404:
            throw RequestError.notFound
        case 500 ... 599:
            throw RequestError.serverError
        default:
            throw RequestError.unexpectedStatusCode(response.statusCode)
        }
    }
    
    private func mapData(todoItem: ToDoItem) -> ElementDTO {
        return ElementDTO(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance.rawValue,
            deadline: todoItem.deadline.map { Int($0.timeIntervalSince1970) },
            done: todoItem.isDone,
            color: "fffff",
            creationDate: Int(todoItem.createdDate.timeIntervalSince1970),
            modificationDate: Int((todoItem.dateOfChange ?? todoItem.createdDate).timeIntervalSince1970),
            lastUpdatedBy: deviceID
        )
    }
    
    private func mapData(element: ElementDTO) -> ToDoItem? {
        guard
            let id = UUID(uuidString: element.id),
            let importance = Importance(rawValue: element.importance),
            let textColor = element.color
        else {
            return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: TimeInterval(element.creationDate))
        let deadline = element.deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let modificationDate = Date(timeIntervalSince1970: TimeInterval(element.modificationDate))
        
        return ToDoItem(
            id: id.uuidString,
            text: element.text,
            importance: importance,
            deadline: deadline,
            isDone: element.done,
            createdDate: creationDate,
            dateOfChange: modificationDate
        )
    }
    
}

enum RequestError: Error {
    case wrongURL(URLComponents)
    case unexpectedResponse
    case badRequest
    case wrongAuth
    case notFound
    case serverError
    case unexpectedStatusCode(Int)
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongURL(let urlComponents):
            return "Could not construct url with components: \(urlComponents)"
        case .unexpectedResponse:
            return "Unexpected response from server"
        case .badRequest:
            return "Wrong request or unsynchronized data"
        case .wrongAuth:
            return "Wrong authorization"
        case .notFound:
            return "Element not found"
        case .serverError:
            return "Server error"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        }
    }
}
