//
//  CollectionViewSwipeActionDelegate.swift
//  RSSFeed
//
//  Created by Mirko Braic on 03.01.2024..
//

import UIKit

protocol CollectionViewSwipeActionDelegate {
    func trailingAction(at indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func leadingAction(at indexPath: IndexPath) -> UISwipeActionsConfiguration?
}
