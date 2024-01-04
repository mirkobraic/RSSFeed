//
//  MainCoordinator.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit
import SafariServices

extension MainCoordinator {
    struct Dependencies {
        let networkService: NetworkService
        let rssParser: RSSParser
        let feedService: RssFeedService
        let storageService: UserDefaultsService
    }
}

class MainCoordinator: Coordinator {
    var children = [Coordinator]()
    var navigationController: UINavigationController

    private let dependencies: Dependencies

    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vm = FeedListViewModel(feedService: dependencies.feedService, storageService: dependencies.storageService)
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
        let vm = FeedDetailsViewModel(feed: feed, feedService: dependencies.feedService)
        vm.coordinator = self
        let vc = FeedDetailsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUrl(_ urlString: String, completion: (() -> Void)?) {
        guard let url = URL(string: urlString) else { return }

        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = .rsTint
        navigationController.present(vc, animated: true, completion: completion)
    }
}
