//
//  CatAPIClientTests.swift
//  NetworkingTests
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Testing
import Domain
@testable import Networking

@Suite(.serialized)
struct CatAPIClientTests {
    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    private func makeClient() -> CatAPIClient {
        CatAPIClient(session: makeSession(), apiKey: "test-key")
    }

    private func httpResponse(_ status: Int, url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    @Test func breedsReturnsDecodedBreeds() async throws {
        let body = #"""
        [{"id":"beng","name":"Bengal","origin":"United States","temperament":"Alert","description":"Desc","life_span":"12 - 15","reference_image_id":"abc123","wikipedia_url":"https://en.wikipedia.org/wiki/Bengal_(cat)"}]
        """#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            (self.httpResponse(200, url: request.url!), body)
        }

        let result = try await makeClient().breeds(page: 0, limit: 1)
        #expect(result.count == 1)
        #expect(result[0].id == "beng")
        #expect(result[0].imageURL == URL(string: "https://cdn2.thecatapi.com/images/abc123.jpg"))
        #expect(result[0].lifeSpan?.minYears == 12)
    }

    @Test func breedsThrowsNetworkErrorOn401() async {
        MockURLProtocol.requestHandler = { request in
            (self.httpResponse(401, url: request.url!), Data())
        }
        await #expect(throws: BreedRepositoryError.network(statusCode: 401)) {
            _ = try await makeClient().breeds(page: 0, limit: 1)
        }
    }

    @Test func breedsThrowsDecodingErrorOnMalformedJSON() async {
        MockURLProtocol.requestHandler = { request in
            (self.httpResponse(200, url: request.url!), Data("not json".utf8))
        }
        await #expect(throws: BreedRepositoryError.decoding) {
            _ = try await makeClient().breeds(page: 0, limit: 1)
        }
    }

    @Test func breedReturnsDecodedSingleBreed() async throws {
        let body = #"""
        {"id":"beng","name":"Bengal","origin":"United States","temperament":"Alert","description":"Desc","life_span":"12 - 15","reference_image_id":"abc123","wikipedia_url":"https://en.wikipedia.org/wiki/Bengal_(cat)"}
        """#.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (self.httpResponse(200, url: request.url!), body)
        }
        let result = try await makeClient().breed(id: "beng")
        #expect(result.name == "Bengal")
    }

    @Test func breedThrowsNotFoundOn404() async {
        MockURLProtocol.requestHandler = { request in
            (self.httpResponse(404, url: request.url!), Data())
        }
        await #expect(throws: BreedRepositoryError.notFound) {
            _ = try await makeClient().breed(id: "missing")
        }
    }

    @Test func searchBreedsReturnsDecodedBreeds() async throws {
        let body = #"""
        [{"id":"beng","name":"Bengal","origin":"United States","temperament":"Alert","description":"Desc","life_span":"12 - 15","reference_image_id":"abc123","wikipedia_url":"https://en.wikipedia.org/wiki/Bengal_(cat)"}]
        """#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.path == "/v1/breeds/search")
            #expect(request.url?.query?.contains("q=ben") == true)
            return (self.httpResponse(200, url: request.url!), body)
        }

        let result = try await makeClient().searchBreeds(query: "ben")
        #expect(result.count == 1)
        #expect(result[0].id == "beng")
    }
}
