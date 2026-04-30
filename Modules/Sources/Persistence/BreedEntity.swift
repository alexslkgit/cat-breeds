import Foundation
import SwiftData

@Model
public final class BreedEntity {
    @Attribute(.unique) public var id: String
    public var name: String
    public var origin: String
    public var temperament: String
    public var breedDescription: String
    public var lifeSpanRaw: String?
    public var referenceImageId: String?
    public var wikipediaURLString: String?
    public var isFavourite: Bool

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        breedDescription: String,
        lifeSpanRaw: String?,
        referenceImageId: String?,
        wikipediaURLString: String?,
        isFavourite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.breedDescription = breedDescription
        self.lifeSpanRaw = lifeSpanRaw
        self.referenceImageId = referenceImageId
        self.wikipediaURLString = wikipediaURLString
        self.isFavourite = isFavourite
    }
}
