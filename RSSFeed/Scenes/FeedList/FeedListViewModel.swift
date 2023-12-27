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
        case feedTapped(RssFeed)
        case addFeedTapped
    }

    struct Output {
        let feedsUpdated: AnyPublisher<[RssFeed], Never>
        let loadingData: AnyPublisher<Bool, Never>
    }

    struct Subjects {
        let feedsUpdated = CurrentValueSubject<[RssFeed], Never>([])
        let loadingData = CurrentValueSubject<Bool, Never>(false)
    }
}

class FeedListViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let subjects = Subjects()

    weak var coordinator: MainCoordinator?
    private let networkService: NetworkService
    private let feedStorage: RssFeedRepositoryType

    private var feeds = [RssFeed]()

    init(networkService: NetworkService, feedStorage: RssFeedRepositoryType) {
        self.networkService = networkService
        self.feedStorage = feedStorage

        do {
            feeds = try feedStorage.getRssFeeds()
            subjects.feedsUpdated.send(feeds)
        } catch {
            Logger.storage.error("Error fetching RSS feeds from storage.")
        }
    }

    func transform(input: AnyPublisher<Input, Never>) -> Output {
        input.sink { [weak self] input in
            guard let self else { return }

            switch input {
            case .feedTapped(let feed):
                coordinator?.openFeedDetails(for: feed)
            case .addFeedTapped:
                coordinator?.presentAddFeedScreen(completion: addNewFeed)
            }
        }
        .store(in: &subscriptions)

        let output = Output(feedsUpdated: subjects.feedsUpdated.eraseToAnyPublisher(),
                            loadingData: subjects.loadingData.eraseToAnyPublisher())
        return output
    }

    private func addNewFeed(with feedUrl: String?) {
        guard let feedUrl else { return }

        feeds.append(RssFeed(url: feedUrl, isFavorite: false))
        // TODO: add fetching of a feed data

        subjects.feedsUpdated.send(feeds)

        // TODO: add storing of a single feed to a persistent storage
        do {
            try feedStorage.saveRssFeeds(feeds)
        } catch {
            Logger.storage.error("Error saving RSS feeds.")
        }
    }
}
