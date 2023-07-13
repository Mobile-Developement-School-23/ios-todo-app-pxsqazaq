//
//  Extentions.swift
//  ToDo
//
//  Created by Arystan on 27.06.2023.
//
import UIKit
import CocoaLumberjack
import CocoaLumberjackSwift

extension UIViewController {
    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
}

extension URLSession {
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await dataTask(for: URLRequest(url: url))
    }
    
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation ({ continuation in
            let task = self.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                }
            }
            if Task.isCancelled {
                task.cancel()
            } else {
                task.resume()
            }
        })
    }
}
