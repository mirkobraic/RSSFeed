//
//  FeedDetailsViewModel.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation
import Combine

extension FeedDetailsViewModel {
    enum Input {
        case feedItemTapped(RssItem.ID)
    }

    struct Output {
        let feedUpdated: AnyPublisher<RssFeed?, Never>
        let loadingData: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    struct Subjects {
        let feedUpdated = CurrentValueSubject<RssFeed?, Never>(nil)
        let loadingData = CurrentValueSubject<Bool, Never>(false)
        let errorMessage = PassthroughSubject<(String, String), Never>()
    }
}

class FeedDetailsViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let subjects = Subjects()

    weak var coordinator: MainCoordinator?
    private var feed: RssFeed
    private let rssParser: RSSParser

    init(feed: RssFeed, rssParser: RSSParser) {
        self.feed = feed
        self.rssParser = rssParser
        
        if feed.items != nil {
            subjects.feedUpdated.send(feed)
        } else {
            fetchFeedItems()
        }
    }

    func transform(input: AnyPublisher<Input, Never>) -> Output {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .feedItemTapped(let itemId):
                if let item = getItem(withId: itemId), let link = item.link {
                    coordinator?.openUrl(link)
                }
            }
        }
        .store(in: &subscriptions)

        let output = Output(feedUpdated: subjects.feedUpdated.eraseToAnyPublisher(),
                            loadingData: subjects.loadingData.eraseToAnyPublisher(),
                            errorMessage: subjects.errorMessage.eraseToAnyPublisher())
        return output
    }

    func getItem(withId id: RssItem.ID) -> RssItem? {
        return feed.items?.first { $0.id == id }
    }

    private func fetchFeedItems() {
        subjects.loadingData.send(true)
        Task {
            do {
                // Parsing directly into the feed so the change is propagated back to the feeds list. Not an ideal solution. Alternative would be to parse feed items from FeedListViewModel, but then details screen would not be pushed until items are loaded.
                try await rssParser.parse(into: feed)
            } catch let error as NetworkError {
                subjects.errorMessage.send(("Network error", "\(error)"))
            } catch is RSSParser.ParserError {
                subjects.errorMessage.send(("Parsing error", "Unable to read RSS data from the provided source. Please verify that the URL corresponds to a valid RSS feed."))
            } catch {
                subjects.errorMessage.send(("Unexpected error", "\(error)"))
            }
            DispatchQueue.main.async {
                self.subjects.loadingData.send(false)
                self.subjects.feedUpdated.send(self.feed)
            }
        }
    }
}
