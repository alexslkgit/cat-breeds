//
//  BreedDetailViewModel.swift
//  BreedDetailFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class BreedDetailViewModel {
    public var breed: Breed?
    public var isLoading: Bool = false
    public var isFavourite: Bool = false
    public var errorMessage: String?

    private let breedRepository: BreedRepository
    private let favouritesStore: FavouritesStore

    public init(breedRepository: BreedRepository, favouritesStore: FavouritesStore) {
        self.breedRepository = breedRepository
        self.favouritesStore = favouritesStore
    }

    public func load(breedId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            breed = try await breedRepository.breed(id: breedId)
            let ids = (try? await favouritesStore.favouriteIDs()) ?? []
            isFavourite = ids.contains(breedId)
        } catch {
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func toggleFavourite() async {
        guard let id = breed?.id else { return }
        let next = !isFavourite
        do {
            try await favouritesStore.setFavourite(next, for: id)
            isFavourite = next
        } catch {
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func startObservingFavourites() async {
        for await ids in favouritesStore.favouriteIDsStream() {
            if let id = breed?.id {
                isFavourite = ids.contains(id)
            }
        }
    }
}
