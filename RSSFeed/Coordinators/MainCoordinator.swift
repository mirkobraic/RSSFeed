//
//  MainCoordinator.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

extension MainCoordinator {
    struct Dependencies {
        let networkService: NetworkService
        let rssParser: RSSParser
        let feedStorage: RssFeedRepositoryType
    }
}

class MainCoordinator: Coordinator {
    var children = [Coordinator]()
    var navigationController: UINavigationController

    private let dependencies: Dependencies

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        let networkService = NetworkService()
        let rssParser = RSSParser(networkService: networkService)
        let feedStorage = RssFeedFileRepository()
        self.dependencies = Dependencies(networkService: networkService,
                                         rssParser: rssParser,
                                         feedStorage: feedStorage)
    }

    func start() {
        let vm = FeedListViewModel(rssParser: dependencies.rssParser,
                                   feedStorage: dependencies.feedStorage)
        vm.coordinator = self
        let vc = FeedListViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: false)
    }

    func presentAddFeedScreen(completion: ((String?) -> Void)?) {
        let ac = UIAlertController(title: "Enter RSS feed", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0].text
            completion?(answer)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        navigationController.present(ac, animated: true)
    }

    func openFeedDetails(for feed: RssFeed) {
        let vm = FeedDetailsViewModel(feed: feed, rssParser: dependencies.rssParser)
        vm.coordinator = self
        let vc = FeedDetailsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // TODO: open safari
    }
}
