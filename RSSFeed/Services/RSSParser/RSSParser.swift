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

        return try parse(from: data)
    }

    func parse(into feed: RssFeed) async throws {
        let data = try await networkService.getData(from: feed.url)
        resetFeed(feed)
        rssFeed = feed
        currentElementPath = ""

        _ = try parse(from: data)
    }

    private func parse(from data: Data) throws -> RssFeed {
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
                currentItem?.imageUrl = value.replacingOccurrences(of: "\\", with: "").extractingUrlFromImgTag()
            } else {
                currentItem?.description = (currentItem?.description ?? "") + value
            }
        case .channelItemContentEncoded:
            if currentItem?.imageUrl == nil {
                currentItem?.imageUrl = value.replacingOccurrences(of: "\\", with: "").extractingUrlFromImgTag()
            }
        case .channelItemLink:
            currentItem?.link = (currentItem?.link ?? "") + value
        case .channelItemCategory:
            if let endIndex = currentItem?.categories?.endIndex, endIndex > 0 {
                currentItem?.categories?[endIndex - 1] += value
            }
        case .channelItemPublicationDate:
            currentItem?.publicationDate = (currentItem?.publicationDate ?? "") + value

         default:
            break
        }
    }

    private func parseElement(_ elementName: String, attributes: [String: String]) {
        guard let elementType = ElementType(rawValue: currentElementPath as String), let rssFeed else { return }
        let currentItem = rssFeed.items?.last

        switch elementType {
        case .channelItem:
            if rssFeed.items == nil {
                rssFeed.items = []
            }
            rssFeed.items?.append(RssItem())
        case .channelItemCategory:
            if rssFeed.items?.last?.categories == nil {
                currentItem?.categories = []
            }
            rssFeed.items?.last?.categories?.append("")
        case .channelItemMediaThumbnail:
            if let imageUrl = attributes["url"] {
                currentItem?.imageUrl = imageUrl
            }
        case .channelItemEnclosure:
            if let imageUrl = attributes["url"], currentItem?.imageUrl == nil {
                currentItem?.imageUrl = imageUrl
            }
        case .channelItemMediaContent:
            if let imageUrl = attributes["url"], currentItem?.imageUrl == nil {
                currentItem?.imageUrl = imageUrl
            }
        default:
            break
        }
    }

    private func isParsingSatisfactory(for feed: RssFeed) -> Bool {
        return feed.title != nil && feed.items != nil
    }

    private func cleanup(feed: RssFeed) {
        feed.title = feed.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        for item in feed.items ?? [] {
            item.title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            item.description = item.description?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let categories = item.categories {
                item.categories = categories.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }

            if let description = item.description {
                let data = Data(description.utf8)
                let htmlString = try? NSMutableAttributedString(data: data,
                                                                options: [.documentType: NSAttributedString.DocumentType.html],
                                                                documentAttributes: nil)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label]
                htmlString?.addAttributes(attributes, range: NSRange(location: 0, length: htmlString?.length ?? 0))
                item.attributedDescription = htmlString
            }
        }
    }

    private func resetFeed(_ feed: RssFeed) {
        feed.title = nil
        feed.description = nil
        feed.imageUrl = nil
        feed.items = nil
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
        parseElement(elementName, attributes: attributeDict)
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
