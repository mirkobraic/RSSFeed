//
//  RssFeedFileRepository.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation

class RssFeedFileRepository: RssFeedRepositoryType {
    let rssFeedFileUrl = FileManager.default.documentsDirectory.appendingPathComponent("rssFeeds")

    func getRssFeeds() throws -> [RssFeedStorageModel] {
        let data = try Data(contentsOf: rssFeedFileUrl)
        let feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        return feeds
    }

    func saveRssFeeds(_ feeds: [RssFeedStorageModel]) throws {
        let data = try JSONEncoder().encode(feeds)
        try data.write(to: rssFeedFileUrl)
    }

    func insertRssFeed(_ feed: RssFeedStorageModel) throws {
        let data = try Data(contentsOf: rssFeedFileUrl)
        var feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        feeds.append(feed)
        let newData = try JSONEncoder().encode(feeds)
        try newData.write(to: rssFeedFileUrl)
    }

    func deleteRssFeed(_ feed: RssFeedStorageModel) throws {
        let data = try Data(contentsOf: rssFeedFileUrl)
        var feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
        feeds.removeAll { $0.url == feed.url }
        let newData = try JSONEncoder().encode(feeds)
        try newData.write(to: rssFeedFileUrl)
    }
}
