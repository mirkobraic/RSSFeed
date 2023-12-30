//
//  NetworkService.swift
//  RSSFeed
//
//  Created by Mirko Braic on 30.12.2023..
//

import Foundation
import OSLog

class NetworkService {
    func getData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString),
              let (data, response) = try? await URLSession.shared.data(from: url) else {
            Logger.network.error("Network error - URL \"\(urlString)\" not supported.")
            throw NetworkError.urlNotSupported
        }

        if let error = checkResponse(response) {
            Logger.network.error("Network error - \(error)")
            throw error
        }

        return data
    }

    private func checkResponse(_ response: URLResponse) -> NetworkError? {
        guard let response = response as? HTTPURLResponse else {
            return NetworkError.noResponse
        }

        switch response.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return NetworkError.clientError(response.statusCode)
        case 500...599:
            return NetworkError.serverError(response.statusCode)
        default:
            return NetworkError.unknownError
        }
    }
}
