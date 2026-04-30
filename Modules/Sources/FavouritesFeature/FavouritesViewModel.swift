import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class FavouritesViewModel {
    public var breeds: [Breed] = []
    public var errorMessage: String?

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
            errorMessage = Self.message(for: error)
        }
    }

    public func removeFavourite(breedId: String) async {
        do {
            try await favouritesStore.setFavourite(false, for: breedId)
            breeds.removeAll { $0.id == breedId }
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
