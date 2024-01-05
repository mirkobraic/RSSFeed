//
//  FeedListViewController+CompositionalLayout.swift
//  RSSFeed
//
//  Created by Mirko Braic on 05.01.2024..
//

import UIKit

extension FeedListViewController {
    func plainList(swipeActionDelegate: CollectionViewSwipeActionDelegate?) -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = swipeActionDelegate?.trailingAction
        configuration.leadingSwipeActionsConfigurationProvider = swipeActionDelegate?.leadingAction
        configuration.backgroundColor = .rsBackground
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
