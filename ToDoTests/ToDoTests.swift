//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Arystan on 12.06.2023.
//

import XCTest
@testable import ToDo

final class ToDoTests: XCTestCase {
    
    func testDataTaskForURLRequest() async throws {
        let url = URL(string: "https://rickandmortyapi.com/api/character")!
        let request = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            
            // Проверяем, что данные и ответ не равны nil
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            
            // Дополнительные проверки, если необходимо
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testDataTaskForInvalidURLRequest() async throws {
        let url = URL(string: "https://invalidurl")! // Некорректный URL
        let request = URLRequest(url: url)
        
        do {
            _ = try await URLSession.shared.dataTask(for: request)
            
            // Если мы попали в эту точку, то запрос должен был завершиться с ошибкой,
            // поэтому тест не должен до этого дойти
            XCTFail("Expected error")
        } catch {
            // Ожидаем ошибку, можно добавить дополнительные проверки
            XCTAssertNotNil(error)
        }
    }
    
//    func testDataTaskForCanceledRequest() async throws {
//        let url = URL(string: "https://api.example.com")!
//        let request = URLRequest(url: url)
//
//        do {
//            let task = try await URLSession.shared.dataTask(for: request)
//
//            // Отменяем запрос с помощью задачи
//            task.cancel()
//
//            // Проверяем, что запрос был отменен
//            XCTAssertTrue(task.isCancelled)
//
//            // Дополнительные проверки, если необходимо
//
//        } catch {
//            XCTFail("Error: \(error)")
//        }
//    }
    
    func testParseJSON() {
        // Given
        let json: [String: Any] = [
            "id": "1",
            "text": "Buy something",
            "importance": "важная",
            "deadline": 1623830400.0,
            "isDone": false,
            "createdDate": 1623772800.0
        ]
        
        // When
        let todoItem = ToDoItem.parse(json: json)
        
        // Then
        XCTAssertEqual(todoItem?.id, "1")
        XCTAssertEqual(todoItem?.text, "Buy something")
        XCTAssertEqual(todoItem?.importance, .high)
        XCTAssertEqual(todoItem?.deadline?.timeIntervalSince1970, 1623830400)
        XCTAssertEqual(todoItem?.isDone, false)
        XCTAssertEqual(todoItem?.createdDate.timeIntervalSince1970, 1623772800)
        XCTAssertNil(todoItem?.dateOfChange)
    }
    
    func testJSON() {
        // Given
        let todoItem = ToDoItem(
            id: "1",
            text: "Buy something",
            importance: .high,
            deadline: Date(timeIntervalSince1970: 1623830400),
            isDone: false,
            createdDate: Date(timeIntervalSince1970: 1623772800),
            dateOfChange: nil
        )
        
        // When
        let json = todoItem.json
        
        // Then
        XCTAssertEqual(json["id"] as? String, "1")
        XCTAssertEqual(json["text"] as? String, "Buy something")
        XCTAssertEqual(json["importance"] as? String, "важная")
        XCTAssertEqual(json["deadline"] as? TimeInterval, 1623830400)
        XCTAssertEqual(json["isDone"] as? Bool, false)
        XCTAssertEqual(json["createdDate"] as? TimeInterval, 1623772800)
        XCTAssertNil(json["dateOfChange"])
    }
    
    func testParseCSV() {
        // Given
        let csvString = """
            ID,Text,Importance,Deadline,IsCompleted,CreationDate,DateOfChange
            1,Task 1,важная,1645926000,true,1645922400,1645922402
            2,Task 2,,1645933200,false,1645929600,
            """
        
        // When
        let todoItems = ToDoItem.parse(csv: csvString)
        
        // Then
        XCTAssertEqual(todoItems.count, 2)
        
        let firstItem = todoItems[0]
        XCTAssertEqual(firstItem.id, "1")
        XCTAssertEqual(firstItem.text, "Task 1")
        XCTAssertEqual(firstItem.importance, .high)
        XCTAssertEqual(firstItem.deadline?.timeIntervalSince1970, 1645926000.0)
        XCTAssertTrue(firstItem.isDone)
        XCTAssertEqual(firstItem.createdDate.timeIntervalSince1970, 1645922400.0)
        XCTAssertEqual(firstItem.dateOfChange?.timeIntervalSince1970, 1645922402.0)
        
        let secondItem = todoItems[1]
        XCTAssertEqual(secondItem.id, "2")
        XCTAssertEqual(secondItem.text, "Task 2")
        XCTAssertEqual(secondItem.importance, .normal)
        XCTAssertEqual(secondItem.deadline?.timeIntervalSince1970, 1645933200.0)
        XCTAssertFalse(secondItem.isDone)
        XCTAssertEqual(secondItem.createdDate.timeIntervalSince1970, 1645929600.0)
        XCTAssertNil(secondItem.dateOfChange)
        
    }
    
    func testParseCSVInvalid() {
        // Given
        let csvString = """
            Invalid CSV String
            """
        
        // When
        let todoItems = ToDoItem.parse(csv: csvString)
        
        // Then
        XCTAssertEqual(todoItems.count, 0)
    }
    
    // MARK: - csvString Tests
    
    func testCSVString() {
        // Given
        let item = ToDoItem(
            id: "1",
            text: "Task 1",
            importance: .normal,
            deadline: Date(timeIntervalSince1970: 1645926000.0),
            isDone: true,
            createdDate: Date(timeIntervalSince1970: 1645922400.0),
            dateOfChange: nil
        )
        
        // When
        let csvString = item.csvString
        
        // Then
        let expectedCSVString = "1,Task 1,,1645926000.0,true,1645922400.0,\n"
        XCTAssertEqual(csvString, expectedCSVString)
    }
}
