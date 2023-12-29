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
    }

    struct Subjects {
        let feedUpdated = CurrentValueSubject<RssFeed?, Never>(nil)
    }
}

class FeedDetailsViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let subjects = Subjects()

    weak var coordinator: MainCoordinator?
    private let feed: RssFeed

    init(feed: RssFeed) {
        self.feed = feed
        subjects.feedUpdated.send(feed)
    }

    func transform(input: AnyPublisher<Input, Never>) -> Output {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .feedItemTapped(let itemId):
                if let item = getItem(withId: itemId) {
                    coordinator?.openUrl(item.link)
                }
            }
        }
        .store(in: &subscriptions)

        let output = Output(feedUpdated: subjects.feedUpdated.eraseToAnyPublisher())
        return output
    }

    func getItem(withId id: RssItem.ID) -> RssItem? {
        return feed.items.first { $0.id == id }
    }
}
