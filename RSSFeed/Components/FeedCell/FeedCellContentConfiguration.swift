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
    var favoriteTapCallback: (() -> Void)?

    func makeContentView() -> UIView & UIContentView {
        return FeedCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> FeedCellContentConfiguration {
        return self
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(imageUrl)
        hasher.combine(isFavorite)
    }

    static func == (lhs: FeedCellContentConfiguration, rhs: FeedCellContentConfiguration) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
