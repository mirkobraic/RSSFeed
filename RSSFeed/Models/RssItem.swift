//
//  RssItem.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation

struct RssItem: Codable, Hashable {
    let title: String
    let link: String
    let categories: [String]
    let description: String
}
