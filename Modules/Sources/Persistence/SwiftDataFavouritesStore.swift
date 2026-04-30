import Foundation
import SwiftData
import Domain

public actor SwiftDataFavouritesStore: FavouritesStore {
    private let modelContainer: ModelContainer
    private lazy var context = ModelContext(modelContainer)
    private let continuation: AsyncStream<Set<String>>.Continuation
    public nonisolated let favouriteIDsStream: AsyncStream<Set<String>>

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        var continuation: AsyncStream<Set<String>>.Continuation!
        self.favouriteIDsStream = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    public func favouriteIDs() async throws -> Set<String> {
        let descriptor = FetchDescriptor<BreedEntity>(
            predicate: #Predicate { $0.isFavourite == true }
        )
        return Set(try context.fetch(descriptor).map(\.id))
    }

    public func setFavourite(_ isFavourite: Bool, for breedID: String) async throws {
        let descriptor = FetchDescriptor<BreedEntity>(
            predicate: #Predicate { $0.id == breedID }
        )
        guard let entity = try context.fetch(descriptor).first else {
            throw BreedRepositoryError.notFound
        }
        entity.isFavourite = isFavourite
        try context.save()
        let snapshot = try await favouriteIDs()
        continuation.yield(snapshot)
    }
}
