//
//  FavouritesStore.swift
//  Domain
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

public protocol FavouritesStore: Sendable {
    func favouriteIDs() async throws -> Set<String>
    func setFavourite(_ isFavourite: Bool, for breedID: String) async throws
    func favouriteIDsStream() -> AsyncStream<Set<String>>
}
