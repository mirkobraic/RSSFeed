//
//  APIError.swift
//  RSSFeed
//
//  Created by Mirko Braic on 30.12.2023..
//

import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case urlNotSupported
    case noResponse
    case clientError(_ code: Int)
    case serverError(_ code: Int)
    case unknownError

    var description: String {
        switch self {
        case .urlNotSupported:
            return "Invalid URL. Please ensure that the provided URL points to a valid source using the secure https:// protocol."
        case .noResponse:
            return "No response. Please try again later."
        case .clientError(let code):
            return "Client error, code: \(code)"
        case .serverError(let code):
            return "Server error, code: \(code)"
        case .unknownError:
            return "Unknown error"
        }
    }
}
