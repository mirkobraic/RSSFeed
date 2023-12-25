//
//  Coordinator.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit

protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
