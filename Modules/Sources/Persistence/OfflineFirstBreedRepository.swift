import Foundation
import SwiftData
import Domain
import Networking

public actor OfflineFirstBreedRepository: BreedRepository {
    private let apiClient: CatAPIClientProtocol
    private let modelContainer: ModelContainer
    private lazy var context = ModelContext(modelContainer)

    public init(apiClient: CatAPIClientProtocol, modelContainer: ModelContainer) {
        self.apiClient = apiClient
        self.modelContainer = modelContainer
    }

    public func breeds(page: Int, limit: Int) async throws -> [Breed] {
        do {
            let remote = try await apiClient.breeds(page: page, limit: limit)
            for breed in remote {
                BreedEntityMapper.toEntity(breed, context: context)
            }
            try context.save()
            return remote
        } catch {
            var descriptor = FetchDescriptor<BreedEntity>(
                sortBy: [SortDescriptor(\BreedEntity.id, order: .forward)]
            )
            descriptor.fetchOffset = page * limit
            descriptor.fetchLimit = limit
            let entities = try context.fetch(descriptor)
            return entities.map(BreedEntityMapper.toDomain)
        }
    }

    public func breed(id: String) async throws -> Breed {
        do {
            let remote = try await apiClient.breed(id: id)
            BreedEntityMapper.toEntity(remote, context: context)
            try context.save()
            return remote
        } catch {
            let descriptor = FetchDescriptor<BreedEntity>(
                predicate: #Predicate { $0.id == id }
            )
            guard let entity = try context.fetch(descriptor).first else {
                throw BreedRepositoryError.notFound
            }
            return BreedEntityMapper.toDomain(entity)
        }
    }

    public func searchBreeds(query: String) async throws -> [Breed] {
        let descriptor = FetchDescriptor<BreedEntity>(
            sortBy: [SortDescriptor(\BreedEntity.name, order: .forward)]
        )
        let entities = try context.fetch(descriptor)
        return entities
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                    || $0.temperament.localizedCaseInsensitiveContains(query)
            }
            .map(BreedEntityMapper.toDomain)
    }
}
