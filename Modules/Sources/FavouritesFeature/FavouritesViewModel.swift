//
//  FavouritesViewModel.swift
//  FavouritesFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class FavouritesViewModel {
    public var breeds: [Breed] = []
    public var errorMessage: String?

    public var averageLifespan: Double? {
        let upperBounds = breeds.compactMap { $0.lifeSpan?.upperBound }
        guard !upperBounds.isEmpty else { return nil }
        let total = upperBounds.reduce(0, +)
        return Double(total) / Double(upperBounds.count)
    }

    private let breedRepository: BreedRepository
    private let favouritesStore: FavouritesStore

    public init(breedRepository: BreedRepository, favouritesStore: FavouritesStore) {
        self.breedRepository = breedRepository
        self.favouritesStore = favouritesStore
    }

    public func load() async {
        do {
            let ids = try await favouritesStore.favouriteIDs()
            var fetched: [Breed] = []
            for id in ids {
                if let breed = try? await breedRepository.breed(id: id) {
                    fetched.append(breed)
                }
            }
            breeds = fetched.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func removeFavourite(breedId: String) async {
        do {
            try await favouritesStore.setFavourite(false, for: breedId)
            breeds.removeAll { $0.id == breedId }
        } catch {
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }
}
