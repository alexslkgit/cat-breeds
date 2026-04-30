import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class BreedListViewModel {
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
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await breedRepository.breeds(page: currentPage, limit: pageSize)
            breeds.append(contentsOf: page)
            currentPage += 1
            if page.count < pageSize {
                hasMore = false
            }
        } catch {
            errorMessage = Self.message(for: error)
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

        isLoading = true
        defer { isLoading = false }

        do {
            let results = try await breedRepository.searchBreeds(query: searchQuery)
            breeds = results
            hasMore = false
        } catch {
            errorMessage = Self.message(for: error)
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
            errorMessage = Self.message(for: error)
        }
    }

    public func startObservingFavourites() async {
        if let initial = try? await favouritesStore.favouriteIDs() {
            favouriteIDs = initial
        }
        for await ids in favouritesStore.favouriteIDsStream {
            favouriteIDs = ids
        }
    }

    private static func message(for error: Error) -> String {
        if let repoError = error as? BreedRepositoryError {
            switch repoError {
            case .offline: return "You appear to be offline."
            case .notFound: return "Breed not found."
            case .decoding: return "Could not read response."
            case .network(let status): return "Network error (\(status))."
            case .unknown: return "Something went wrong."
            }
        }
        return error.localizedDescription
    }
}
