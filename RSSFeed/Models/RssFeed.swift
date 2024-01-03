//
//  RssFeed.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation

class RssFeed: Identifiable {
    let id = UUID()
    var url: String
    var isFavorite: Bool
    var title: String?
    var description: String?
    var imageUrl: String?
    var items: [RssItem]?

    var readArticles: [String] = []

    init(url: String) {
        self.url = url
        isFavorite = false
        title = nil
        description = nil
        imageUrl = nil
        items = nil
    }

    init(from feed: RssFeedStorageModel) {
        url = feed.url
        isFavorite = feed.isFavorite
        title = feed.title
        description = feed.description
        imageUrl = feed.imageUrl

        readArticles = feed.readArticles
    }
}
