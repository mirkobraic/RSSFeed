//
//  RSSParser+enums.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation

extension RSSParser {
    enum ParserError: Error, CustomStringConvertible {
        case parsingFailed

        var description: String {
            switch self {
            case .parsingFailed:
                return "Invalid RSS feed format"
            }
        }
    }

    enum ElementType: String {
        case channelTitle       = "rss/channel/title"
        case channelImageUrl    = "rss/channel/image/url"
        case channelDescription = "rss/channel/description"

        case channelItem                = "rss/channel/item"
        case channelItemTitle           = "rss/channel/item/title"
        case channelItemDescription     = "rss/channel/item/description"
        case channelItemLink            = "rss/channel/item/link"
        case channelItemCategory        = "rss/channel/item/category"
        case channelItemPublicationDate = "rss/channel/item/pubDate"
        case channelItemMediaThumbnail  = "rss/channel/item/media:thumbnail"
        case channelItemEnclosure       = "rss/channel/item/enclosure"
        case channelItemMediaContent    = "rss/channel/item/media:content"
        case channelItemContentEncoded  = "rss/channel/item/content:encoded"
    }
}
