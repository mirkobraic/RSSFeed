//
//  Sequence+.swift
//  RSSFeed
//
//  Created by Mirko Braic on 05.01.2024..
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
