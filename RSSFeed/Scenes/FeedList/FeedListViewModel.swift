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
        case toggleFavorites(RssFeed.ID)
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
    private var feedService: RssFeedService

    init(feedService: RssFeedService) {
        self.feedService = feedService
        subjects.feedsUpdated.send(feedService.getFeeds())
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
                feedService.deleteFeed(id: feedId)
            case .toggleFavorites(let feedId):
                feedService.toggleFavorite(id: feedId)
            }
        }
        .store(in: &subscriptions)

        let output = Output(feedsUpdated: subjects.feedsUpdated.eraseToAnyPublisher(),
                            loadingData: subjects.loadingData.eraseToAnyPublisher(),
                            errorMessage: subjects.errorMessage.eraseToAnyPublisher())
        return output
    }

    func getFeed(withId id: RssFeed.ID) -> RssFeed? {
        return feedService.getFeed(withId: id)
    }

    private func addNewFeed(with feedUrl: String?) {
        guard let feedUrl else { return }

        subjects.loadingData.send(true)
        Task {
            let error = await feedService.addNewFeed(url: feedUrl)
            subjects.loadingData.send(false)
            subjects.feedsUpdated.send(feedService.getFeeds())

            if let error {
                switch error {
                case .duplicateFeed:
                    subjects.errorMessage.send(("Duplicate feed", "The RSS feed you entered is already saved in the application. Please enter a unique RSS feed."))
                case .networkError(let error):
                    subjects.errorMessage.send(("Network error", "\(error)"))
                case .parserError:
                    subjects.errorMessage.send(("Parsing error", "Unable to read RSS data from the provided source. Please verify that the URL corresponds to a valid RSS feed."))
                case .unknownError:
                    subjects.errorMessage.send(("Unexpected error", "\(error)"))
                }
            }
        }
    }
}
