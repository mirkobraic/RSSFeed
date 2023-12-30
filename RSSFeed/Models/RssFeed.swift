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
    var imageUrl: String?
    var title: String?
    var description: String?
    var items: [RssItem]?
    var isFavorite: Bool
    
    init(url: String) {
        self.url = url
        imageUrl = nil
        title = nil
        description = nil
        items = nil
        isFavorite = false
    }

    init(from feed: RssFeedStorageModel) {
        url = feed.url
        imageUrl = feed.imageUrl
        title = feed.title
        description = feed.description
        isFavorite = feed.isFavorite
    }
}
