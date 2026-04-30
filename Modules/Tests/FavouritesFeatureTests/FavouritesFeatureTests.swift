//
//  FavouritesFeatureTests.swift
//  FavouritesFeatureTests
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Testing
import Foundation
import Domain
@testable import FavouritesFeature

@Test @MainActor func averageLifespanIsNilWhenNoBreeds() {
    let viewModel = FavouritesViewModel(
        breedRepository: StubBreedRepository(),
        favouritesStore: StubFavouritesStore()
    )

    #expect(viewModel.averageLifespan == nil)
}

@Test @MainActor func averageLifespanIsNilWhenAllLifeSpansAreNil() {
    let viewModel = FavouritesViewModel(
        breedRepository: StubBreedRepository(),
        favouritesStore: StubFavouritesStore()
    )
    viewModel.breeds = [
        makeBreed(id: "a", lifeSpan: nil),
        makeBreed(id: "b", lifeSpan: nil)
    ]

    #expect(viewModel.averageLifespan == nil)
}

@Test @MainActor func averageLifespanAveragesUpperBoundsAcrossBreeds() {
    let viewModel = FavouritesViewModel(
        breedRepository: StubBreedRepository(),
        favouritesStore: StubFavouritesStore()
    )
    viewModel.breeds = [
        makeBreed(id: "a", lifeSpan: LifeSpan(minYears: 10, maxYears: 14)),
        makeBreed(id: "b", lifeSpan: LifeSpan(minYears: 12, maxYears: 18))
    ]

    #expect(viewModel.averageLifespan == 16.0)
}

@Test @MainActor func averageLifespanSkipsBreedsWithNilLifeSpan() {
    let viewModel = FavouritesViewModel(
        breedRepository: StubBreedRepository(),
        favouritesStore: StubFavouritesStore()
    )
    viewModel.breeds = [
        makeBreed(id: "a", lifeSpan: LifeSpan(minYears: 10, maxYears: 14)),
        makeBreed(id: "b", lifeSpan: nil),
        makeBreed(id: "c", lifeSpan: LifeSpan(minYears: 12, maxYears: 18))
    ]

    #expect(viewModel.averageLifespan == 16.0)
}

private func makeBreed(id: String, lifeSpan: LifeSpan?) -> Breed {
    Breed(
        id: id,
        name: id,
        origin: "",
        temperament: "",
        description: "",
        lifeSpan: lifeSpan,
        referenceImageId: nil,
        wikipediaURL: nil
    )
}

private struct StubBreedRepository: BreedRepository {
    func breeds(page: Int, limit: Int) async throws -> [Breed] { [] }
    func breed(id: String) async throws -> Breed {
        throw BreedRepositoryError.notFound
    }
    func searchBreeds(query: String) async throws -> [Breed] { [] }
}

private struct StubFavouritesStore: FavouritesStore {
    func favouriteIDs() async throws -> Set<String> { [] }
    func setFavourite(_ isFavourite: Bool, for breedID: String) async throws {}
    func favouriteIDsStream() -> AsyncStream<Set<String>> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
