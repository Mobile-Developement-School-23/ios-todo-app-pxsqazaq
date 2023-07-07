//
//  FileCacheTests.swift
//  ToDoTests
//
//  Created by Arystan on 16.06.2023.
//

import Foundation
import XCTest
@testable import ToDo

final class FileCacheTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var fileCache: FileCache!
    let testFilePath = "Users/new/Documents/todoItems.json"
    
    // MARK: - Test's Lifecycle
    
    override func setUp() {
        super.setUp()
        fileCache = FileCache(filepath: testFilePath)
    }
    
    override func tearDown() {
        super.tearDown()
        fileCache = nil
        try? FileManager.default.removeItem(atPath: testFilePath)
    }
    
    // MARK: - Test Cases
    
    func testAddTodoItem() {
        // Given
        let item = createTestItem()
        // When
        fileCache.add(todoItem: item)
        // Then
        XCTAssertEqual(fileCache.todoItems.count, 1)
        XCTAssertTrue(fileCache.todoItems.contains(where: { $0.id == item.id }))
    }
    
    func testAddDuplicateTodoItem() {
        let item = createTestItem()
        
        fileCache.add(todoItem: item)
        fileCache.add(todoItem: item)
        
        XCTAssertEqual(fileCache.todoItems.count, 1)
    }
    
    func testRemoveTodoItem() {
        let item = createTestItem()
        fileCache.add(todoItem: item)
        
        fileCache.remove(id: item.id)
        
        XCTAssertEqual(fileCache.todoItems.count, 0)
        XCTAssertFalse(fileCache.todoItems.contains(where: { $0.id == item.id }))
    }
    
    func testSaveAndLoadFromFile() {
        let item1 = createTestItem()
        let item2 = createTestItem()
        
        fileCache.add(todoItem: item1)
        fileCache.add(todoItem: item2)
        fileCache.saveToJSONFile()
        
        XCTAssertEqual(fileCache.todoItems.count, 2)
        XCTAssertTrue(fileCache.todoItems.contains(where: { $0.id == item1.id }))
        XCTAssertTrue(fileCache.todoItems.contains(where: { $0.id == item2.id }))
    }
    
    func testSaveAndLoadFromCSVFile() {
        let item1 = createTestItem()
        let item2 = createTestItem()
        
        fileCache.add(todoItem: item1)
        fileCache.add(todoItem: item2)
        fileCache.saveToCSVFile()
        
        XCTAssertEqual(fileCache.todoItems.count, 2)
        XCTAssertTrue(fileCache.todoItems.contains(where: { $0.id == item1.id }))
        XCTAssertTrue(fileCache.todoItems.contains(where: { $0.id == item2.id }))
    }
    
    // MARK: - Helper Methods
    
    func createTestItem() -> ToDoItem {
        return ToDoItem(
            id: UUID().uuidString,
            text: "Test Item",
            importance: .normal,
            deadline: Date(),
            isDone: false,
            createdDate: Date(),
            dateOfChange: nil
        )
    }
}
