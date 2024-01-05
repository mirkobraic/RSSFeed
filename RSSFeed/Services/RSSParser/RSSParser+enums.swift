//
//  RSSParser+enums.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation

extension RSSParser {
    enum FeedType: String {
        case rss
        case feed
    }
    
    enum ParserError: Error, CustomStringConvertible {
        case parsingFailed

        var description: String {
            switch self {
            case .parsingFailed:
                return "Invalid RSS feed format"
            }
        }
    }

    enum ElementType {
        case title
        case imageUrl
        case description

        case item
        case itemTitle
        case itemDescription
        case itemLink
        case itemCategory
        case itemPublicationDate
        case itemMediaThumbnail
        case itemEnclosure
        case itemMediaContent
        case itemContentEncoded

        static func from(rssType: RssElementType) -> ElementType {
            switch rssType {
            case .channelTitle:                 return .title
            case .channelImageUrl:              return .imageUrl
            case .channelDescription:           return .description
            case .channelItem:                  return .item
            case .channelItemTitle:             return .itemTitle
            case .channelItemDescription:       return .itemDescription
            case .channelItemLink:              return .itemLink
            case .channelItemCategory:          return .itemCategory
            case .channelItemPublicationDate:   return .itemPublicationDate
            case .channelItemMediaThumbnail:    return .itemMediaThumbnail
            case .channelItemEnclosure:         return .itemEnclosure
            case .channelItemMediaContent:      return .itemMediaContent
            case .channelItemContentEncoded:    return .itemContentEncoded
            }
        }

        static func from(feedType: FeedElementType) -> ElementType {
            switch feedType {
            case .feedTitle:                 return .title
            case .feedImageUrl:              return .imageUrl
            case .feedSummary:               return .description
            case .feedEntry:                 return .item
            case .feedEntryTitle:            return .itemTitle
            case .feedEntryDescription:      return .itemDescription
            case .feedEntryLink:             return .itemLink
            case .feedEntryMediaThumbnail:   return .itemMediaThumbnail
            }
        }
    }

    enum RssElementType: String {
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

    enum FeedElementType: String {
        case feedTitle      = "feed/title"
        case feedImageUrl   = "feed/icon"
        case feedSummary    = "feed/sumary"

        case feedEntry                = "feed/entry"
        case feedEntryTitle           = "feed/entry/title"
        case feedEntryDescription     = "feed/entry/summary"
        case feedEntryLink            = "feed/entry/id"
        case feedEntryMediaThumbnail  = "feed/entry/media:thumbnail"
    }
}
