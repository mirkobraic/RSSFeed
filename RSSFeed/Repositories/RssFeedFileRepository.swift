//
//  RssFeedFileRepository.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation
import OSLog

class RssFeedFileRepository: RssFeedRepositoryType {
    let rssFeedFileUrl = FileManager.default.documentsDirectory.appendingPathComponent("rssFeeds")

    func getRssFeeds() throws -> [RssFeedStorageModel] {
        do {
            let data = try Data(contentsOf: rssFeedFileUrl)
            let feeds = try JSONDecoder().decode([RssFeedStorageModel].self, from: data)
            return feeds
        } catch {
            // catching for the sake of logging
            Logger.storage.error("RSS storage error - unable to fetch rss feeds: \(error)")
            throw error
        }
    }

    func saveRssFeeds(_ feeds: [RssFeedStorageModel]) throws {
        do {
            let data = try JSONEncoder().encode(feeds)
            try data.write(to: rssFeedFileUrl)
        } catch {
            // catching for the sake of logging
            Logger.storage.error("RSS storage error - unable to save rss feeds: \(error)")
        }
    }
}
