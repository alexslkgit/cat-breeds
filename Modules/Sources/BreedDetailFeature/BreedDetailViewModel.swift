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
            errorMessage = Self.message(for: error)
        }
    }

    public func toggleFavourite() async {
        guard let id = breed?.id else { return }
        let next = !isFavourite
        do {
            try await favouritesStore.setFavourite(next, for: id)
            isFavourite = next
        } catch {
            errorMessage = Self.message(for: error)
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
