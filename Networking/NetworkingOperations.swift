////
////  NetworkingOperations.swift
////  ToDo
////
////  Created by Arystan on 12.07.2023.
////
//
//import Foundation
//
//private func loadTodoList() {
//    Task(priority: .userInitiated) { [weak self] in
//        guard let self = self else { return }
//        do {
//            let todoList = try await self.network.getItemList()
//            self.data = todoList
//            checkStatus()
//        } catch {
//            self.isDirty = true
//        }
//    }
//}
//
//func deleteToDoNetwork(id: String) {
//
//    guard let itemIndex = data.firstIndex(where: { $0.id == id })
//    else { return }
//    data.remove(at: itemIndex)
//
//        if self.isDirty {
//            loadTodoList()
//        }
//
//        Task {
//            do {
//                _ = try await network.deleteElement(by: id)
//                self.isDirty = false
//            } catch {
//                self.isDirty = true
//            }
//        }
//    }
//
//func addToDoNetwork(item: ToDoItem) {
//
//        if self.isDirty {
//            loadTodoList()
//        }
//
//        Task {
//            do {
//                _ = try await network.postElement(with: item)
//                loadTodoList()
//                self.isDirty = false
//            } catch {
//                self.isDirty = true
//            }
//        }
//    }
//
//    func changeToDoNetwork(item: ToDoItem) {
//
//        if self.isDirty {
//            loadTodoList()
//        }
//
//        Task {
//            do {
//                _ = try await network.putElement(by: item)
//                loadTodoList()
//                self.isDirty = false
//            } catch {
//                self.isDirty = true
//            }
//        }
//    }
