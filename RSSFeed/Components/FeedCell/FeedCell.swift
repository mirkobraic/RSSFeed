//
//  FeedCell.swift
//  RSSFeed
//
//  Created by Mirko Braic on 31.12.2023..
//

import UIKit

class FeedCell: UICollectionViewCell {
    var feed: RssFeed?

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        guard let feed else { return }

        var contentConfig = FeedCellContentConfiguration().updated(for: state)
        contentConfig.title = feed.title
        contentConfig.description = feed.description
        if let url = feed.imageUrl {
            contentConfig.imageUrl = URL(string: url)
        }
        contentConfig.isFavorite = feed.isFavorite

        contentConfiguration = contentConfig
    }
}
