//
//  UserDefaultsService.swift
//  RSSFeed
//
//  Created by Mirko Braic on 04.01.2024..
//

import Foundation

class UserDefaultsService {
    @UserDefault(key: "sortOrder", defaultValue: SortOrder.default.rawValue)
    private var sortOrderString: String
    var sortOrder: SortOrder {
        get {
            SortOrder(rawValue: sortOrderString) ?? .default
        }
        set {
            sortOrderString = newValue.rawValue
        }
    }
}
