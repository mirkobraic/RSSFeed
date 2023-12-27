//
//  RssFeedRepositoryType.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation

protocol RssFeedRepositoryType {
    func getRssFeeds() throws -> [RssFeed]
    func saveRssFeeds(_ feeds: [RssFeed]) throws
    func insertRssFeed(_ feed: RssFeed) throws
    func deleteRssFeed(_ feed: RssFeed) throws
}
