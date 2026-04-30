import Foundation
import Domain

struct BreedDTO: Decodable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: String
    let referenceImageId: String?
    let wikipediaURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, origin, temperament, description
        case lifeSpan = "life_span"
        case referenceImageId = "reference_image_id"
        case wikipediaURL = "wikipedia_url"
    }

    func toDomain() -> Breed {
        Breed(
            id: id,
            name: name,
            origin: origin,
            temperament: temperament,
            description: description,
            lifeSpan: LifeSpan(rawValue: lifeSpan),
            referenceImageId: referenceImageId,
            wikipediaURL: wikipediaURL.flatMap(URL.init(string:))
        )
    }
}
