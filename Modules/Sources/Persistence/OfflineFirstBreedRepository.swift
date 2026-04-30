//
//  OfflineFirstBreedRepository.swift
//  Persistence
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

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
            try upsertCache(remote)
            return remote
        } catch let error where Self.isOffline(error) {
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
            try BreedEntityMapper.toEntity(remote, context: context)
            try context.save()
            return remote
        } catch let error where Self.isOffline(error) {
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
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            let descriptor = FetchDescriptor<BreedEntity>(
                sortBy: [SortDescriptor(\BreedEntity.name, order: .forward)]
            )
            let entities = try context.fetch(descriptor)
            return entities.map(BreedEntityMapper.toDomain)
        }
        do {
            let remote = try await apiClient.searchBreeds(query: trimmed)
            try upsertCache(remote)
            return remote
        } catch let error where Self.isOffline(error) {
            let descriptor = FetchDescriptor<BreedEntity>(
                sortBy: [SortDescriptor(\BreedEntity.name, order: .forward)]
            )
            let entities = try context.fetch(descriptor)
            return entities
                .filter {
                    $0.name.localizedCaseInsensitiveContains(trimmed)
                        || $0.temperament.localizedCaseInsensitiveContains(trimmed)
                }
                .map(BreedEntityMapper.toDomain)
        }
    }

    private func upsertCache(_ breeds: [Breed]) throws {
        for breed in breeds {
            try BreedEntityMapper.toEntity(breed, context: context)
        }
        try context.save()
    }

    private static func isOffline(_ error: Error) -> Bool {
        if let repoError = error as? BreedRepositoryError, repoError == .offline {
            return true
        }
        if let urlError = error as? URLError,
           urlError.code == .notConnectedToInternet || urlError.code == .timedOut {
            return true
        }
        return false
    }
}
