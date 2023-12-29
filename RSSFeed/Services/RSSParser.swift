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
    var xmlParser: XMLParser!

    var rssFeed: RssFeed?
    var parserError: ParserError?
    // The current path along the XML's elements. Ex. rss/channel/item/title
    var currentElementPath: NSString = ""

    func parse(from urlString: String) async -> Result<RssFeed, ParserError> {
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url) else {
            Logger.parsing.error("RSSParser error: URL \"\(urlString)\" not supported.")
            return .failure(.urlNotSupported)
        }

        resetDataForNewParsing()
        rssFeed = RssFeed(url: urlString)

        let parser = XMLParser(data: data)
        parser.delegate = self
        let _ = parser.parse()

        if let parserError {
            Logger.parsing.error("RSSParser error: \(parserError)")
            return .failure(parserError)
        }

        if let rssFeed {
            cleanup(feed: rssFeed)
            return .success(rssFeed)
        }

        Logger.parsing.error("RSSParser error: unknown error occured.")
        return .failure(.unknownError)
    }

    private func parseCharacters(_ string: String) {
        guard let elementType = ElementType(rawValue: currentElementPath as String), let rssFeed else { return }
        let currentItem = rssFeed.items.last

        switch elementType {
        case .channelTitle:
            rssFeed.title += string
        case .channelImageUrl:
            rssFeed.imageUrl += string
        case .channelDescription:
            rssFeed.description += string
        case .channelItemTitle:
            currentItem?.title += string
        case .channelItemDescription:
            if string.containsImgTag() {
                currentItem?.imageUrl += string
            } else {
                currentItem?.description += string
            }
        case .channelItemLink:
            currentItem?.link += string
        case .channelItemCategory:
            if let endIndex = currentItem?.categories.endIndex, endIndex > 0 {
                currentItem?.categories[endIndex - 1] += string
            }
        case .channelItemPublicationDate:
            rssFeed.items.last?.publicationDate += string

        case .channelItem:
            break
        }
    }

    private func parseElement(_ elementName: String) {
        guard let elementType = ElementType(rawValue: currentElementPath as String), let rssFeed else { return }

        switch elementType {
        case .channelItem:
            rssFeed.items.append(RssItem())
        case .channelItemCategory:
            rssFeed.items.last?.categories.append("")
        default:
            break
        }
    }

    private func resetDataForNewParsing() {
        rssFeed = nil
        parserError = nil
        currentElementPath = ""
    }

    private func cleanup(feed: RssFeed) {
        for item in feed.items {
            item.description = item.description.trimmingCharacters(in: .whitespacesAndNewlines)
            item.imageUrl = item.imageUrl.replacingOccurrences(of: "\\", with: "").extractingUrlFromImgTag() ?? ""

            let data = Data(item.description.utf8)
            let htmlString = try? NSMutableAttributedString(data: data,
                                                            options: [.documentType: NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            htmlString?.addAttributes(attributes, range: NSRange(location: 0, length: htmlString?.length ?? 0))
            item.attributedDescription = htmlString
        }
    }
}

// MARK: - XMLParserDelegate
extension RSSParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, 
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
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
