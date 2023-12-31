//
//  CompositionalLayouts.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

class CompositionalLayouts {
    private init() { }

    static func list() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.backgroundColor = UIColor.rsBackground
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
