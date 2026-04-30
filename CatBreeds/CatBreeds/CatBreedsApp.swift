//
//  CatBreedsApp.swift
//  CatBreeds
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import SwiftData
import Domain
import Networking
import Persistence

@MainActor
final class AppDependencies {
    
    private static let apiKeyInfoPlistKey = "CAT_API_KEY"
    private static let urlCacheMemoryBytes = 50 * 1024 * 1024
    private static let urlCacheDiskBytes = 200 * 1024 * 1024

    let breedRepository: BreedRepository
    let favouritesStore: FavouritesStore

    init() {
        URLCache.shared = URLCache(
            memoryCapacity: Self.urlCacheMemoryBytes,
            diskCapacity: Self.urlCacheDiskBytes
        )

        let modelContainer: ModelContainer
        do {
            modelContainer = try PersistenceContainer.makeContainer()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }

        let apiKey = (Bundle.main.object(forInfoDictionaryKey: Self.apiKeyInfoPlistKey) as? String) ?? ""
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
            MainTabView(
                breedRepository: dependencies.breedRepository,
                favouritesStore: dependencies.favouritesStore
            )
        }
    }
}
