//
//  CatAPIClient.swift
//  Networking
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Domain

public final class CatAPIClient: CatAPIClientProtocol {
    private static let baseURLString = "https://api.thecatapi.com/v1"
    private static let breedsPath = "breeds"
    private static let breedsSearchPath = "breeds/search"
    private static let apiKeyHeader = "x-api-key"
    private static let limitQueryItem = "limit"
    private static let pageQueryItem = "page"
    private static let searchQueryItem = "q"

    private static let baseURL: URL = {
        guard let url = URL(string: baseURLString) else {
            preconditionFailure("Invalid Cat API base URL: \(baseURLString)")
        }
        return url
    }()

    private let session: URLSession
    private let apiKey: String

    public init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    public func breeds(page: Int, limit: Int) async throws -> [Breed] {
        let url = Self.baseURL
            .appending(path: Self.breedsPath)
            .appending(queryItems: [
                URLQueryItem(name: Self.limitQueryItem, value: String(limit)),
                URLQueryItem(name: Self.pageQueryItem, value: String(page)),
            ])
        let dtos: [BreedDTO] = try await perform(request(for: url))
        return dtos.map { $0.toDomain() }
    }

    public func breed(id: String) async throws -> Breed {
        let url = Self.baseURL
            .appending(path: Self.breedsPath)
            .appending(path: id)
        let dto: BreedDTO = try await perform(request(for: url))
        return dto.toDomain()
    }

    public func searchBreeds(query: String) async throws -> [Breed] {
        let url = Self.baseURL
            .appending(path: Self.breedsSearchPath)
            .appending(queryItems: [
                URLQueryItem(name: Self.searchQueryItem, value: query),
            ])
        let dtos: [BreedDTO] = try await perform(request(for: url))
        return dtos.map { $0.toDomain() }
    }

    private func request(for url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.setValue(apiKey, forHTTPHeaderField: Self.apiKeyHeader)
        return req
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .timedOut {
            throw BreedRepositoryError.offline
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch {
            throw BreedRepositoryError.unknown
        }
        guard let http = response as? HTTPURLResponse else {
            throw BreedRepositoryError.unknown
        }
        switch http.statusCode {
        case 200..<300:
            break
        case 404:
            throw BreedRepositoryError.notFound
        default:
            throw BreedRepositoryError.network(statusCode: http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch is DecodingError {
            throw BreedRepositoryError.decoding
        }
    }
}
