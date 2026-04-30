//
//  SwiftDataFavouritesStore.swift
//  Persistence
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import SwiftData
import Domain

public actor SwiftDataFavouritesStore: FavouritesStore {
    private let modelContainer: ModelContainer
    private lazy var context = ModelContext(modelContainer)
    private var continuations: [UUID: AsyncStream<Set<String>>.Continuation] = [:]

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
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
        for continuation in continuations.values {
            continuation.yield(snapshot)
        }
    }

    public nonisolated func favouriteIDsStream() -> AsyncStream<Set<String>> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.register(continuation: continuation, id: id) }
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task { await self.unregister(id: id) }
            }
        }
    }

    private func register(continuation: AsyncStream<Set<String>>.Continuation, id: UUID) async {
        continuations[id] = continuation
        if let snapshot = try? await favouriteIDs() {
            continuation.yield(snapshot)
        }
    }

    private func unregister(id: UUID) {
        continuations[id] = nil
    }
}
