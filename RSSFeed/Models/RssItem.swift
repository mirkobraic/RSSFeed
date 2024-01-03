//
//  RssItem.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation

class RssItem: Identifiable {
    let id = UUID()
    var title: String?
    var link: String?
    var categories: [String]?
    var description: String?
    var attributedDescription: NSMutableAttributedString?
    var publicationDate: String?
    var imageUrl: String?

    var isSeen = false
}
