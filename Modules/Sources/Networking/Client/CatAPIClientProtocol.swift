//
//  CatAPIClientProtocol.swift
//  Networking
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Domain

public protocol CatAPIClientProtocol: Sendable {
    func breeds(page: Int, limit: Int) async throws -> [Breed]
    func breed(id: String) async throws -> Breed
    func searchBreeds(query: String) async throws -> [Breed]
}
