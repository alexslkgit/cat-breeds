//
//  PersistenceTests.swift
//  PersistenceTests
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Testing
import Foundation
import SwiftData
import Domain
@testable import Persistence

@MainActor
@Test func toEntityInsertsAndUpsertsByID() throws {
    let schema = Schema([BreedEntity.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)

    let breed = Breed(
        id: "abys",
        name: "Abyssinian",
        origin: "Egypt",
        temperament: "Active, Energetic",
        description: "Active and playful.",
        lifeSpan: LifeSpan(minYears: 14, maxYears: 15),
        referenceImageId: "0XYvRd7oD",
        wikipediaURL: URL(string: "https://en.wikipedia.org/wiki/Abyssinian_cat")
    )

    let inserted = try BreedEntityMapper.toEntity(breed, context: context)
    try context.save()
    #expect(inserted.id == "abys")
    #expect(inserted.isFavourite == false)

    inserted.isFavourite = true
    try context.save()

    let updatedDomain = Breed(
        id: "abys",
        name: "Abyssinian (renamed)",
        origin: breed.origin,
        temperament: breed.temperament,
        description: breed.description,
        lifeSpan: breed.lifeSpan,
        referenceImageId: breed.referenceImageId,
        wikipediaURL: breed.wikipediaURL
    )
    let upserted = try BreedEntityMapper.toEntity(updatedDomain, context: context)
    try context.save()

    #expect(upserted.id == "abys")
    #expect(upserted.name == "Abyssinian (renamed)")
    #expect(upserted.isFavourite == true)

    let count = try context.fetchCount(FetchDescriptor<BreedEntity>())
    #expect(count == 1)
}

@Test func toDomainRoundTripsFields() {
    let entity = BreedEntity(
        id: "beng",
        name: "Bengal",
        origin: "United States",
        temperament: "Active",
        breedDescription: "Spotted coat.",
        lifeSpanRaw: "12 - 15",
        referenceImageId: "ref-1",
        wikipediaURLString: "https://en.wikipedia.org/wiki/Bengal_cat"
    )

    let domain = BreedEntityMapper.toDomain(entity)
    #expect(domain.id == "beng")
    #expect(domain.name == "Bengal")
    #expect(domain.lifeSpan == LifeSpan(minYears: 12, maxYears: 15))
    #expect(domain.wikipediaURL?.absoluteString == "https://en.wikipedia.org/wiki/Bengal_cat")
}
