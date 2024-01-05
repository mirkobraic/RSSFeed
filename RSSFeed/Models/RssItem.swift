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

    var formattedDate: String? {
        guard let publicationDate else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, dd MMM yyyy HH:mm:ss Z"
        guard let date = dateFormatter.date(from: publicationDate) else { return publicationDate }
        dateFormatter.dateFormat = "EE, dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
}
