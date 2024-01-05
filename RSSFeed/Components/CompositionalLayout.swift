//
//  CompositionalLayouts.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit
enum CompositionalGroupAlignment {
    case vertical
    case horizontal
}

struct CompositionalLayout {
    private init() { }
    static func createItem(width: NSCollectionLayoutDimension,
                           height: NSCollectionLayoutDimension) -> NSCollectionLayoutItem {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height))
        return item
    }

    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {

        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: items)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: items)
        }
    }

    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            item: NSCollectionLayoutItem,
                            count: Int) -> NSCollectionLayoutGroup {

        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitem: item, count: count)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: count)
        }
    }
}
