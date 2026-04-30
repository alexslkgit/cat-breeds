//
//  LifeSpanTests.swift
//  DomainTests
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import Testing
@testable import Domain

@Test func lifeSpanParsesStandardRange() {
    let parsed = LifeSpan(rawValue: "12 - 15")
    #expect(parsed?.minYears == 12)
    #expect(parsed?.maxYears == 15)
}

@Test func lifeSpanParsesRangeWithoutSpaces() {
    let parsed = LifeSpan(rawValue: "12-15")
    #expect(parsed?.minYears == 12)
    #expect(parsed?.maxYears == 15)
}

@Test func lifeSpanParsesSingleValue() {
    let parsed = LifeSpan(rawValue: "12")
    #expect(parsed?.minYears == 12)
    #expect(parsed?.maxYears == 12)
}

@Test func lifeSpanToleratesIrregularWhitespace() {
    let parsed = LifeSpan(rawValue: "  14  -  16  ")
    #expect(parsed?.minYears == 14)
    #expect(parsed?.maxYears == 16)
}

@Test func lifeSpanReturnsNilForEmptyString() {
    #expect(LifeSpan(rawValue: "") == nil)
}

@Test func lifeSpanReturnsNilForNonNumericInput() {
    #expect(LifeSpan(rawValue: "abc") == nil)
}

@Test func lifeSpanReturnsNilForTrailingHyphen() {
    #expect(LifeSpan(rawValue: "12 - ") == nil)
}

@Test func lifeSpanReturnsNilForLeadingHyphen() {
    #expect(LifeSpan(rawValue: "- 15") == nil)
}

@Test func lifeSpanUpperBoundReturnsMax() {
    let span = LifeSpan(minYears: 10, maxYears: 14)
    #expect(span.upperBound == 14)
}

@Test func lifeSpanAverageIsMidpoint() {
    let span = LifeSpan(minYears: 10, maxYears: 14)
    #expect(span.average == 12.0)
}
