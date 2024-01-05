//
//  FeedItemCellContentConfiguration.swift
//  RSSFeed
//
//  Created by Mirko Braic on 02.01.2024..
//

import UIKit

struct FeedItemCellContentConfiguration: UIContentConfiguration, Hashable {
    var title: String?
    var date: String?
    var description: String?
    var attributedDescription: NSAttributedString?
    var imageUrl: URL?
    var isSeen: Bool = false

    func makeContentView() -> UIView & UIContentView {
        return FeedItemCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> FeedItemCellContentConfiguration {
        return self
    }
}
