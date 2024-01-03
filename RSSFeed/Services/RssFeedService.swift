//
//  RssFeedsService.swift
//  RSSFeed
//
//  Created by Mirko Braic on 03.01.2024..
//

import Foundation

enum RssFeedServiceError: Error {
    case duplicateFeed
    case networkError(NetworkError)
    case parserError(RSSParser.ParserError)
    case unknownError(Error)
}

class RssFeedService {
    private let feedStorage: RssFeedRepositoryType
    private let rssParser: RSSParser
    private var feeds = [RssFeed]()

    init(feedStorage: RssFeedRepositoryType, rssParser: RSSParser) {
        self.feedStorage = feedStorage
        self.rssParser = rssParser
        fetchFeeds()
    }

    private func fetchFeeds() {
        let storedFeeds = (try? feedStorage.getRssFeeds()) ?? []
        feeds = storedFeeds.map { RssFeed(from: $0) }
    }

    func getFeeds() -> [RssFeed] {
        return feeds
    }

    func getFeed(withId id: RssFeed.ID) -> RssFeed? {
        return feeds.first { $0.id == id }
    }

    func addNewFeed(url: String) async -> RssFeedServiceError? {
        let adjustedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines).appendingHttpsIfMissing()
        guard feeds.contains(where: { $0.url == adjustedUrl }) == false else {
            return .duplicateFeed
        }

        async let newFeed = rssParser.parse(from: adjustedUrl)
        do {
            try await feeds.append(newFeed)
            save()
        } catch let error as NetworkError {
            return .networkError(error)
        } catch let error as RSSParser.ParserError {
            return .parserError(error)
        } catch {
            return .unknownError(error)
        }
        return nil
    }


    func deleteFeed(id: RssFeed.ID) {
        feeds.removeAll { $0.id == id }
        save()
    }

    func toggleFavorite(id: RssFeed.ID) {
        if let feed = feeds.first(where: { $0.id == id }) {
            feed.isFavorite.toggle()
            save()
        }
    }

    func fetchItems(for feed: RssFeed) async -> RssFeedServiceError? {
        do {
            try await rssParser.parse(into: feed)
            for item in feed.items ?? [] {
                if let link = item.link, feed.readArticles.contains(link) {
                    item.isSeen = true
                }
            }
        } catch let error as NetworkError {
            return .networkError(error)
        } catch let error as RSSParser.ParserError {
            return .parserError(error)
        } catch {
            return .unknownError(error)
        }
        return nil
    }

    func save() {
        try? feedStorage.saveRssFeeds(feeds.map { RssFeedStorageModel(from: $0)} )
    }
}
