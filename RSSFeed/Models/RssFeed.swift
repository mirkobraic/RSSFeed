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

    var imageUrl: String = ""
    var title: String = ""
    var description: String = ""
    var items: [RssItem] = []

    init(url: String, isFavorite: Bool = false) {
        self.url = url
        self.isFavorite = isFavorite
    }
}
