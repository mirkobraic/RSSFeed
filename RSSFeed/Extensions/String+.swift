//
//  String+.swift
//  RSSFeed
//
//  Created by Mirko Braic on 28.12.2023..
//

import Foundation

extension String {
    func appendingHttpsIfMissing() -> String {
        if contains("http://") {
            return replacingOccurrences(of: "http://", with: "https://")
        } else if contains("https://") == false {
            return "https://" + self
        } else {
            return self
        }
    }

    func extractingUrlFromImgTag() -> String? {
        let regexPattern = #"<img[^>]+src\s*=\s*["']([^"'>]+)["'][^>]*>"#
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let nsString = self as NSString

        let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        for match in matches ?? [] {
            if let range = Range(match.range(at: 1), in: self) {
                // returning the first match
                return String(self[range])
            }
        }
        return nil
    }

    func containsImgTag() -> Bool {
        let regex = try? NSRegularExpression(pattern: "<img[^>]+>", options: .caseInsensitive)
        let range = NSRange(startIndex..<endIndex, in: self)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
}
