//
//  FileManager+.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import Foundation

extension FileManager {
    var documentsDirectory: URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
