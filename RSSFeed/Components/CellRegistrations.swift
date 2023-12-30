//
//  CellRegistrations.swift
//  RSSFeed
//
//  Created by Mirko Braic on 29.12.2023..
//

import UIKit

class CellRegistrations {
    private init() { }

    static func feedListCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, RssFeed> {
        return .init { cell, indexPath, rssFeed in
            var content = cell.defaultContentConfiguration()
            content.text = rssFeed.title ?? rssFeed.url
            content.secondaryText = rssFeed.description
            cell.contentConfiguration = content
        }
    }

    static func feedItemListCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, RssItem> {
        return .init { cell, indexPath, rssItem in
            var content = cell.defaultContentConfiguration()
            content.text = rssItem.title
            if let attributedDescription = rssItem.attributedDescription {
                content.secondaryAttributedText = attributedDescription
            } else {
                content.secondaryText = rssItem.description
            }
            cell.contentConfiguration = content
        }
    }
}
