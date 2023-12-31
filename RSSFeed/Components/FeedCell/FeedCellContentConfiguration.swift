//
//  FeedCellContentConfiguration.swift
//  RSSFeed
//
//  Created by Mirko Braic on 31.12.2023..
//

import UIKit

struct FeedCellContentConfiguration: UIContentConfiguration, Hashable {
    var title: String?
    var description: String?
    var imageUrl: URL?
    var isFavorite: Bool = false

    func makeContentView() -> UIView & UIContentView {
        return FeedCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> FeedCellContentConfiguration {
        return self
    }
}
