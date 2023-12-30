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
}
