//
//  RSSParser.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation
import OSLog
import UIKit

class RSSParser: NSObject {
    private let networkService: NetworkService
    private var xmlParser: XMLParser!
    private var rssFeed: RssFeed!
    // The current path along the XML's elements. Ex. rss/channel/item/title
    private var currentElementPath: NSString = ""

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func parse(from url: String) async throws -> RssFeed {
        let data = try await networkService.getData(from: url)

        rssFeed = RssFeed(url: url)
        currentElementPath = ""

        let parser = XMLParser(data: data)
        parser.delegate = self
        let succeeded = parser.parse()

        if isParsingSatisfactory(for: rssFeed), succeeded {
            cleanup(feed: rssFeed)
            return rssFeed
        } else {
            Logger.parsing.error("RSSParser error - parsing unsuccessful.")
            throw ParserError.parsingFailed
        }
    }

    func parse(into feed: RssFeed) async throws {
        let data = try await networkService.getData(from: feed.url)

        rssFeed = feed
        currentElementPath = ""

        let parser = XMLParser(data: data)
        parser.delegate = self
        let succeeded = parser.parse()

        if isParsingSatisfactory(for: rssFeed), succeeded {
            cleanup(feed: rssFeed)
        } else {
            Logger.parsing.error("RSSParser error - parsing unsuccessful.")
            throw ParserError.parsingFailed
        }
    }

    private func parseCharacters(_ value: String) {
        guard let elementType = ElementType(rawValue: currentElementPath as String), let rssFeed else { return }
        let currentItem = rssFeed.items?.last

        switch elementType {
        case .channelTitle:
            rssFeed.title = (rssFeed.title ?? "") + value
        case .channelImageUrl:
            rssFeed.imageUrl = (rssFeed.imageUrl ?? "") + value
        case .channelDescription:
            rssFeed.description = (rssFeed.description ?? "") + value
        case .channelItemTitle:
            currentItem?.title = (currentItem?.title ?? "") + value
        case .channelItemDescription:
            if value.containsImgTag() {
                currentItem?.imageUrl = (currentItem?.imageUrl ?? "") + value
            } else {
                currentItem?.description = (currentItem?.description ?? "") + value
            }
        case .channelItemLink:
            currentItem?.link = (currentItem?.link ?? "") + value
        case .channelItemCategory:
            if let endIndex = currentItem?.categories?.endIndex, endIndex > 0 {
                currentItem?.categories?[endIndex - 1] += value
            }
        case .channelItemPublicationDate:
            currentItem?.publicationDate = (currentItem?.publicationDate ?? "") + value

        case .channelItem:
            break
        }
    }

    private func parseElement(_ elementName: String) {
        guard let elementType = ElementType(rawValue: currentElementPath as String), let rssFeed else { return }

        switch elementType {
        case .channelItem:
            if rssFeed.items == nil {
                rssFeed.items = []
            }
            rssFeed.items?.append(RssItem())
        case .channelItemCategory:
            if rssFeed.items?.last?.categories == nil {
                rssFeed.items?.last?.categories = []
            }
            rssFeed.items?.last?.categories?.append("")
        default:
            break
        }
    }

    private func isParsingSatisfactory(for feed: RssFeed) -> Bool {
        return feed.title != nil && feed.items != nil
    }

    private func cleanup(feed: RssFeed) {
        for item in feed.items ?? [] {
            item.description = item.description?.trimmingCharacters(in: .whitespacesAndNewlines)
            item.imageUrl = item.imageUrl?.replacingOccurrences(of: "\\", with: "").extractingUrlFromImgTag() ?? ""

            if let description = item.description {
                let data = Data(description.utf8)
                let htmlString = try? NSMutableAttributedString(data: data,
                                                                options: [.documentType: NSAttributedString.DocumentType.html],
                                                                documentAttributes: nil)
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
                htmlString?.addAttributes(attributes, range: NSRange(location: 0, length: htmlString?.length ?? 0))
                item.attributedDescription = htmlString
            }
        }
    }
}

// MARK: - XMLParserDelegate
extension RSSParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, 
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        
        currentElementPath = currentElementPath.appendingPathComponent(elementName) as NSString
        parseElement(elementName)
    }

    func parser(_ parser: XMLParser, 
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        currentElementPath = currentElementPath.deletingLastPathComponent as NSString
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            parseCharacters(string)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        parseCharacters(string)
    }
}
