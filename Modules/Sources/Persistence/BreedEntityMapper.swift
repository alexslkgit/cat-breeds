import Foundation
import SwiftData
import Domain

public enum BreedEntityMapper {
    public static func toDomain(_ entity: BreedEntity) -> Breed {
        Breed(
            id: entity.id,
            name: entity.name,
            origin: entity.origin,
            temperament: entity.temperament,
            description: entity.breedDescription,
            lifeSpan: entity.lifeSpanRaw.flatMap(LifeSpan.init(rawValue:)),
            referenceImageId: entity.referenceImageId,
            wikipediaURL: entity.wikipediaURLString.flatMap(URL.init(string:))
        )
    }

    @discardableResult
    public static func toEntity(_ breed: Breed, context: ModelContext) -> BreedEntity {
        let id = breed.id
        let descriptor = FetchDescriptor<BreedEntity>(predicate: #Predicate { $0.id == id })
        let lifeSpanRaw = breed.lifeSpan.map { "\($0.minYears) - \($0.maxYears)" }
        let wikipediaURLString = breed.wikipediaURL?.absoluteString

        if let existing = try? context.fetch(descriptor).first {
            existing.name = breed.name
            existing.origin = breed.origin
            existing.temperament = breed.temperament
            existing.breedDescription = breed.description
            existing.lifeSpanRaw = lifeSpanRaw
            existing.referenceImageId = breed.referenceImageId
            existing.wikipediaURLString = wikipediaURLString
            return existing
        }

        let entity = BreedEntity(
            id: breed.id,
            name: breed.name,
            origin: breed.origin,
            temperament: breed.temperament,
            breedDescription: breed.description,
            lifeSpanRaw: lifeSpanRaw,
            referenceImageId: breed.referenceImageId,
            wikipediaURLString: wikipediaURLString,
            isFavourite: false
        )
        context.insert(entity)
        return entity
    }
}
