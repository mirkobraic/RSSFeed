//
//  RssFeedRepositoryType.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation

protocol RssFeedRepositoryType {
    func getRssFeeds() throws -> [RssFeedStorageModel]
    func saveRssFeeds(_ feeds: [RssFeedStorageModel]) throws
    func insertRssFeed(_ feed: RssFeedStorageModel) throws
    func deleteRssFeed(_ feed: RssFeedStorageModel) throws
}
