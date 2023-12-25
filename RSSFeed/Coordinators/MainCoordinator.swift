//
//  MainCoordinator.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

class MainCoordinator: Coordinator {
    var children = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vm = FeedListViewModel()
        let vc = FeedListViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: false)
    }
}
