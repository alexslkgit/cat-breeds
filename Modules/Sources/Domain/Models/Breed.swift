import Foundation

public struct Breed: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description: String
    public let lifeSpan: LifeSpan?
    public let referenceImageId: String?
    public let wikipediaURL: URL?

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        lifeSpan: LifeSpan?,
        referenceImageId: String?,
        wikipediaURL: URL?
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.lifeSpan = lifeSpan
        self.referenceImageId = referenceImageId
        self.wikipediaURL = wikipediaURL
    }

    public var imageURL: URL? {
        guard let referenceImageId, !referenceImageId.isEmpty else { return nil }
        return URL(string: "https://cdn2.thecatapi.com/images/\(referenceImageId).jpg")
    }
}
