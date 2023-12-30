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

        let storedFeeds = (try? feedStorage.getRssFeeds()) ?? []
        feeds = storedFeeds.map { RssFeed(from: $0) }
        subjects.feedsUpdated.send(feeds)
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
                    print(feed)
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
        guard feeds.contains(where: { $0.url == adjustedUrl }) == false else {
            subjects.errorMessage.send(("Duplicate feed", "The RSS feed you entered is already saved in the application. Please enter a unique RSS feed."))
            return
        }

        subjects.loadingData.send(true)
        Task {
            do {
                let newFeed = try await rssParser.parse(from: adjustedUrl)
                feeds.append(newFeed)
                try? feedStorage.saveRssFeeds(feeds.map { RssFeedStorageModel(from: $0) })
            } catch let error as NetworkError {
                subjects.errorMessage.send(("Network error", "\(error)"))
            } catch is RSSParser.ParserError {
                subjects.errorMessage.send(("Parsing error", "Unable to read RSS data from the provided source. Please verify that the URL corresponds to a valid RSS feed."))
            } catch {
                subjects.errorMessage.send(("Unexpected error", "\(error)"))
            }
            subjects.loadingData.send(false)
            subjects.feedsUpdated.send(feeds)
        }
    }
}
