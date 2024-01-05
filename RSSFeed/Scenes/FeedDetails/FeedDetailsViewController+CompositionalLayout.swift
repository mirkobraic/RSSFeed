//
//  FeedDetailsViewController+CompositionalLayout.swift
//  RSSFeed
//
//  Created by Mirko Braic on 05.01.2024..
//

import UIKit

extension FeedDetailsViewController {
    func collectionLayout(expandCategories: Bool) -> UICollectionViewCompositionalLayout {
        return .init { section, environment in
            let sectionIdentifier = self.dataSource.snapshot().sectionIdentifiers[section]

            switch sectionIdentifier {
            case .categories:
                if expandCategories {
                    return Self.getExpendedCategoriesSection()
                } else {
                    return Self.getCollapsedCategoriesSection()
                }
            case .items:
                return Self.getFeedItemsSection()
            }
        }
    }

    private static func getExpendedCategoriesSection() -> NSCollectionLayoutSection {
        let item = CompositionalLayout.createItem(width: .estimated(50), height: .absolute(35))

        let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .estimated(50), height: .absolute(35), items: [item])
        group.interItemSpacing = .fixed(10)

        let outerGroup = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .estimated(500), items: [group])
        outerGroup.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(24))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: CategoryHeader.defaultElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private static func getCollapsedCategoriesSection() -> NSCollectionLayoutSection {
        let item = CompositionalLayout.createItem(width: .estimated(50), height: .absolute(35))

        let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .estimated(50), height: .absolute(35), items: [item])
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(24))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: CategoryHeader.defaultElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private static func getFeedItemsSection() -> NSCollectionLayoutSection {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .estimated(400))
        let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .estimated(400), items: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        return section
    }
}
