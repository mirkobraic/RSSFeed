//
//  UserDefault.swift
//  RSSFeed
//
//  Created by Mirko Braic on 04.01.2024..
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults

    private let publisher: CurrentValueSubject<Value, Never>

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = .standard
        self.publisher = CurrentValueSubject<Value, Never>(defaultValue)
        self.publisher.send(wrappedValue)
    }

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }
}

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(key: key, defaultValue: nil)
    }
}
