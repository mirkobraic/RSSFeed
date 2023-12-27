//
//  ReuseIdentifiable.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

protocol ReuseIdentifiable: AnyObject {
    static var defaultReuseIdentifier: String { get }
    static var defaultElementKind: String { get }
}

extension ReuseIdentifiable {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }

    static var defaultElementKind: String {
        return "kind.\(NSStringFromClass(self))"
    }
}

extension UITableViewCell: ReuseIdentifiable { }
extension UICollectionReusableView: ReuseIdentifiable { }
