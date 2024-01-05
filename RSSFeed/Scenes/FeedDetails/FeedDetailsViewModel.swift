//
//  FeedDetailsViewModel.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import Foundation
import Combine

extension FeedDetailsViewModel {
    struct Input {
        let feedItemTapped = PassthroughSubject<RssItem.ID, Never>()
        let categoryTapped = PassthroughSubject<String, Never>()
        let searchTextUpdated = PassthroughSubject<String, Never>()
    }

    struct Output {
        let feedUpdated: AnyPublisher<RssFeed?, Never>
        let itemsUpdated: AnyPublisher<[RssItem], Never>
        let categoriesUpdated: AnyPublisher<[String], Never>
        let loadingData: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    struct Subjects {
        let feedUpdated = CurrentValueSubject<RssFeed?, Never>(nil)
        let itemsUpdated = CurrentValueSubject<[RssItem], Never>([])
        let categoriesUpdated = CurrentValueSubject<[String], Never>([])
        let loadingData = CurrentValueSubject<Bool, Never>(false)
        let errorMessage = PassthroughSubject<(String, String), Never>()
    }
}

class FeedDetailsViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let subjects = Subjects()

    weak var coordinator: MainCoordinator?
    private let feedService: RssFeedService
    private var feed: RssFeed

    private var allCategories = [String]()
    private var filteringCategories = Set<String>()
    private var searchText = ""
    private var feedItemsFiltered: [RssItem] {
        guard var items = feed.items else { return [] }

        if searchText.isEmpty == false {
            items = items.filter {
                let range = $0.title?.range(of: searchText, options: .caseInsensitive)
                return range != nil
            }
        }
        if filteringCategories.isEmpty == false {
            items = items.filter { item in
                let categoriesSet = Set(item.categories ?? [])
                let hasMatchingCategories = categoriesSet.intersection(filteringCategories).isEmpty == false
                return hasMatchingCategories
            }
        }
        return items
    }

    init(feed: RssFeed, feedService: RssFeedService) {
        self.feed = feed
        self.feedService = feedService

        if let items = feed.items {
            subjects.feedUpdated.send(feed)
            subjects.itemsUpdated.send(feedItemsFiltered)
            allCategories = findCategories(in: items)
            subjects.categoriesUpdated.send(Array(allCategories))
        } else {
            fetchFeedItems()
        }
    }

    func transform(input: Input) -> Output {
        input.feedItemTapped
            .sink { [weak self] itemId in
                guard let self else { return }
                if let item = getItem(withId: itemId), let link = item.link {
                    coordinator?.openUrl(link) {
                        item.isSeen = true
                    }
                }
            }
            .store(in: &subscriptions)

        input.categoryTapped
            .sink { [weak self] category in
                guard let self else { return }
                if filteringCategories.contains(category) {
                    filteringCategories.remove(category)
                } else {
                    filteringCategories.insert(category)
                }
                subjects.itemsUpdated.send(feedItemsFiltered)
            }
            .store(in: &subscriptions)

        input.searchTextUpdated
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self else { return }
                self.searchText = searchText
                subjects.itemsUpdated.send(feedItemsFiltered)
                if searchText.isEmpty {
                    subjects.categoriesUpdated.send(allCategories)
                } else {
                    let currentCategories = findCategories(in: feedItemsFiltered)
                    subjects.categoriesUpdated.send(currentCategories)
                }
            }
            .store(in: &subscriptions)

        let output = Output(feedUpdated: subjects.feedUpdated.eraseToAnyPublisher(),
                            itemsUpdated: subjects.itemsUpdated.eraseToAnyPublisher(),
                            categoriesUpdated: subjects.categoriesUpdated.eraseToAnyPublisher(),
                            loadingData: subjects.loadingData.eraseToAnyPublisher(),
                            errorMessage: subjects.errorMessage.eraseToAnyPublisher())
        return output
    }

    func getItem(withId id: RssItem.ID) -> RssItem? {
        return feed.items?.first { $0.id == id }
    }

    private func findCategories(in items: [RssItem]) -> [String] {
        if items.isEmpty { return allCategories }
        return items
            .compactMap { $0.categories }
            .flatMap { $0 }
            .uniqued()
    }

    private func fetchFeedItems() {
        subjects.loadingData.send(true)
        Task {
            // Parsing directly into the feed so the change is propagated back to the feeds list. Not an ideal solution. Alternative would be to parse feed items from FeedListViewModel, but then details screen would not be pushed until items are loaded.
            let error = await feedService.fetchItems(for: feed)
            DispatchQueue.main.async {
                self.subjects.loadingData.send(false)
                self.subjects.feedUpdated.send(self.feed)
                self.subjects.itemsUpdated.send(self.feedItemsFiltered)
                self.allCategories = self.findCategories(in: self.feed.items ?? [])
                self.subjects.categoriesUpdated.send(self.allCategories)
            }

            if let error {
                switch error {
                case .networkError(let error):
                    subjects.errorMessage.send(("Network error", "\(error)"))
                case .parserError:
                    subjects.errorMessage.send(("Parsing error", "Unable to read RSS data from the provided source. Please verify that the URL corresponds to a valid RSS feed."))
                case .unknownError:
                    subjects.errorMessage.send(("Unexpected error", "\(error)"))
                case .duplicateFeed:
                    break
                }
            }
        }
    }
}
