//
//  Logger+.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation

import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let storage = Logger(subsystem: subsystem, category: "storage")
    
    static let network = Logger(subsystem: subsystem, category: "network")

    static let parsing = Logger(subsystem: subsystem, category: "parsing")

}
