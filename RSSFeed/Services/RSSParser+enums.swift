//
//  RSSParser+enums.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation

extension RSSParser {
    enum ParserError: Error {
        case urlNotSupported
        case unknownError
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
    }
}
