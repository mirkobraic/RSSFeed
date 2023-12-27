//
//  CompositionalLayouts.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

class CompositionalLayouts {
    static var list: UICollectionViewCompositionalLayout = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }()
}
