import SwiftUI
import SwiftData
import Domain
import Networking
import Persistence

@MainActor
final class AppDependencies {
    let breedRepository: BreedRepository
    let favouritesStore: FavouritesStore

    init() {
        let modelContainer: ModelContainer
        do {
            modelContainer = try PersistenceContainer.makeContainer()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }

        let apiKey = (Bundle.main.object(forInfoDictionaryKey: "CAT_API_KEY") as? String) ?? ""
        let apiClient = CatAPIClient(apiKey: apiKey)

        self.breedRepository = OfflineFirstBreedRepository(
            apiClient: apiClient,
            modelContainer: modelContainer
        )
        self.favouritesStore = SwiftDataFavouritesStore(modelContainer: modelContainer)
    }
}

@main
struct CatBreedsApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView(
                breedRepository: dependencies.breedRepository,
                favouritesStore: dependencies.favouritesStore
            )
        }
    }
}
