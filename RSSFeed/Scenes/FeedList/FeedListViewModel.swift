//
//  FeedListViewModel.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation
import Combine
import OSLog

extension FeedListViewModel {
    enum Input {
        case feedTapped(RssFeed.ID)
        case addFeedTapped
        case deleteFeed(RssFeed.ID)
    }

    struct Output {
        let feedsUpdated: AnyPublisher<[RssFeed], Never>
        let loadingData: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    struct Subjects {
        let feedsUpdated = CurrentValueSubject<[RssFeed], Never>([])
        let loadingData = CurrentValueSubject<Bool, Never>(false)
        let errorMessage = PassthroughSubject<(String, String), Never>()
    }
}

class FeedListViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let subjects = Subjects()

    weak var coordinator: MainCoordinator?
    private let rssParser: RSSParser
    private let feedStorage: RssFeedRepositoryType

    private var feeds = [RssFeed]()

    init(rssParser: RSSParser, feedStorage: RssFeedRepositoryType) {
        self.rssParser = rssParser
        self.feedStorage = feedStorage

        do {
            subjects.loadingData.send(true)
            let storedFeeds = try feedStorage.getRssFeeds()

            Task {
                feeds = await storedFeeds.asyncMap { storedFeed in
                    let result = await rssParser.parse(from: storedFeed.url)
                    if case .success(let feed) = result {
                        feed.isFavorite = storedFeed.isFavorite
                        return feed
                    }
                    return RssFeed(url: storedFeed.url, isFavorite: storedFeed.isFavorite)
                }

                subjects.loadingData.send(false)
                subjects.feedsUpdated.send(feeds)
            }
        } catch {
            subjects.loadingData.send(false)
            subjects.feedsUpdated.send(feeds)
            Logger.storage.error("Error fetching RSS feeds from storage: \(error)")
        }
    }

    func transform(input: AnyPublisher<Input, Never>) -> Output {
        input.sink { [weak self] input in
            guard let self else { return }

            switch input {
            case .feedTapped(let feedId):
                if let feed = getFeed(withId: feedId) {
                    coordinator?.openFeedDetails(for: feed)
                }
            case .addFeedTapped:
                coordinator?.presentAddFeedScreen(completion: addNewFeed)
            case .deleteFeed(let feedId):
                if let feed = getFeed(withId: feedId) {
                    // TODO: //
                }
            }
        }
        .store(in: &subscriptions)

        let output = Output(feedsUpdated: subjects.feedsUpdated.eraseToAnyPublisher(),
                            loadingData: subjects.loadingData.eraseToAnyPublisher(),
                            errorMessage: subjects.errorMessage.eraseToAnyPublisher())
        return output
    }

    func getFeed(withId id: RssFeed.ID) -> RssFeed? {
        return feeds.first { $0.id == id }
    }

    private func addNewFeed(with feedUrl: String?) {
        guard let feedUrl else { return }
        let adjustedUrl = feedUrl.trimmingCharacters(in: .whitespacesAndNewlines).appendingHttpsIfMissing()

        

        if feeds.contains(where: { $0.url == adjustedUrl}) {
            self.subjects.errorMessage.send(("Duplicate feed", "RSS feed you enterd is already stored in the app."))
            return
        }

        subjects.loadingData.send(true)
        Task {
            let result = await rssParser.parse(from: adjustedUrl)
            subjects.loadingData.send(false)

            switch result {
            case .success(let newFeed):
                feeds.append(newFeed)
                subjects.feedsUpdated.send(feeds)
                do {
                    try feedStorage.saveRssFeeds(feeds.map { RssFeedStorageModel(url: $0.url, isFavorite: $0.isFavorite) })
                } catch {
                    Logger.storage.error("Error saving RSS feeds: \(error)")
                }
            case .failure(_):
                self.subjects.errorMessage.send(("Invalid RSS source", "Please ensure that the provided URL points to a valid RSS source and uses the secure 'https://' protocol."))
            }
        }
    }
}
