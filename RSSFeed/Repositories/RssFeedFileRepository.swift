//
//  RssFeedFileRepository.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation

class RssFeedFileRepository: RssFeedRepositoryType {
    let rssFeedFileUrl = FileManager.default.documentsDirectory.appendingPathComponent("rssFeeds")

    func getRssFeeds() throws -> [RssFeed] {
        let data = try Data(contentsOf: rssFeedFileUrl)
        let feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        return feeds.map { RssFeed(url: $0.url, isFavorite: $0.isFavorite) }
    }

    func saveRssFeeds(_ feeds: [RssFeed]) throws {
        let storageFeeds = feeds.map { RssFeedStorageModel(url: $0.url, isFavorite: $0.isFavorite) }
        let data = try JSONEncoder().encode(storageFeeds)
        try data.write(to: rssFeedFileUrl)
    }

    func insertRssFeed(_ feed: RssFeed) throws {
        let data = try Data(contentsOf: rssFeedFileUrl)
        var feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        feeds.append(RssFeedStorageModel(url: feed.url, isFavorite: feed.isFavorite))
        let newData = try JSONEncoder().encode(feeds)
        try newData.write(to: rssFeedFileUrl)
    }

    func deleteRssFeed(_ feed: RssFeed) throws {
        let data = try Data(contentsOf: rssFeedFileUrl)
        var feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        feeds.removeAll { $0.url == feed.url }
        let newData = try JSONEncoder().encode(feeds)
        try newData.write(to: rssFeedFileUrl)
    }
}
