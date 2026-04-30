import Foundation
import SwiftData

public enum PersistenceContainer {
    public static func makeContainer() throws -> ModelContainer {
        let schema = Schema([BreedEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
