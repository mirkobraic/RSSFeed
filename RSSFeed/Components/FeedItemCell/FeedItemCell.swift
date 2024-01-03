//
//  FeedItemCell.swift
//  RSSFeed
//
//  Created by Mirko Braic on 02.01.2024..
//

import UIKit

class FeedItemCell: UICollectionViewCell {
    var item: RssItem?

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        guard let item else { return }

        var contentConfig = FeedItemCellContentConfiguration().updated(for: state)
        contentConfig.title = item.title
        if let attributedDescription = item.attributedDescription {
            contentConfig.attributedDescription = attributedDescription
        } else {
            contentConfig.description = item.description
        }
        if let url = item.imageUrl {
            contentConfig.imageUrl = URL(string: url)
        }
        contentConfig.isSeen = item.isSeen

        var backgroundConfig = UIBackgroundConfiguration.listPlainCell().updated(for: state)
        backgroundConfig.cornerRadius = 10
        if state.isSelected {
            backgroundConfig.backgroundColor = .rsSecondaryBackgroundHighlighted
        } else {
            backgroundConfig.backgroundColor = .rsSecondaryBackground
        }

        contentConfiguration = contentConfig
        backgroundConfiguration = backgroundConfig
    }
}
