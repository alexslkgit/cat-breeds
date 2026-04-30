//
//  BreedListViewModel.swift
//  BreedsListFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class BreedListViewModel {
    private static let searchDebounceNanoseconds: UInt64 = 300_000_000

    public var breeds: [Breed] = []
    public var searchQuery: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var currentPage: Int = 0
    public var hasMore: Bool = true
    public var favouriteIDs: Set<String> = []

    private let breedRepository: BreedRepository
    private let favouritesStore: FavouritesStore
    private let pageSize: Int
    private var searchTask: Task<Void, Never>?

    public init(
        breedRepository: BreedRepository,
        favouritesStore: FavouritesStore,
        pageSize: Int = 20
    ) {
        self.breedRepository = breedRepository
        self.favouritesStore = favouritesStore
        self.pageSize = pageSize
    }

    public func loadNextPage() async {
        guard !isLoading, hasMore else { return }
        let capturedPage = currentPage
        let capturedSearchEmpty = searchQuery.isEmpty
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await breedRepository.breeds(page: capturedPage, limit: pageSize)
            guard capturedPage == currentPage,
                  capturedSearchEmpty == searchQuery.isEmpty else { return }
            breeds.append(contentsOf: page)
            currentPage += 1
            if page.count < pageSize {
                hasMore = false
            }
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            guard capturedPage == currentPage,
                  capturedSearchEmpty == searchQuery.isEmpty else { return }
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func queryDidChange() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.searchDebounceNanoseconds)
            if Task.isCancelled { return }
            await self?.search()
        }
    }

    public func search() async {
        if searchQuery.isEmpty {
            breeds = []
            currentPage = 0
            hasMore = true
            await loadNextPage()
            return
        }

        let capturedQuery = searchQuery
        isLoading = true
        defer { isLoading = false }

        do {
            let results = try await breedRepository.searchBreeds(query: capturedQuery)
            guard capturedQuery == searchQuery else { return }
            breeds = results
            hasMore = false
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            guard capturedQuery == searchQuery else { return }
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func toggleFavourite(breedId: String) async {
        let next = !favouriteIDs.contains(breedId)
        do {
            try await favouritesStore.setFavourite(next, for: breedId)
            if next {
                favouriteIDs.insert(breedId)
            } else {
                favouriteIDs.remove(breedId)
            }
        } catch {
            errorMessage = BreedRepositoryError.displayMessage(for: error)
        }
    }

    public func startObservingFavourites() async {
        if let initial = try? await favouritesStore.favouriteIDs() {
            favouriteIDs = initial
        }
        for await ids in favouritesStore.favouriteIDsStream() {
            favouriteIDs = ids
        }
    }
}
