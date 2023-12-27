//
//  RssFeed.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation

struct RssFeed: Hashable {
    var url: String
    var isFavorite: Bool

    var imageUrl: URL?
    var title: String?
    var desc: String?
    var items: [RssItem] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
