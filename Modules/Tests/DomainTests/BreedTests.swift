//
//  BreedTests.swift
//  DomainTests
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Foundation
import Testing
@testable import Domain

private func makeBreed(referenceImageId: String?) -> Breed {
    Breed(
        id: "abys",
        name: "Abyssinian",
        origin: "Egypt",
        temperament: "Active",
        description: "Sample",
        lifeSpan: nil,
        referenceImageId: referenceImageId,
        wikipediaURL: nil
    )
}

@Test func breedImageURLIsBuiltFromReferenceImageId() {
    let breed = makeBreed(referenceImageId: "abc123")
    #expect(breed.imageURL == URL(string: "https://cdn2.thecatapi.com/images/abc123.jpg"))
}

@Test func breedImageURLIsNilWhenReferenceImageIdIsNil() {
    let breed = makeBreed(referenceImageId: nil)
    #expect(breed.imageURL == nil)
}

@Test func breedImageURLIsNilWhenReferenceImageIdIsEmpty() {
    let breed = makeBreed(referenceImageId: "")
    #expect(breed.imageURL == nil)
}
