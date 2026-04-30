# Cat Breeds

A SwiftUI iOS app that browses cat breeds from [The Cat API](https://thecatapi.com), with offline support, search, and favourites.

## Architecture

The codebase is split between an iOS app target (`CatBreeds/`) and a local Swift Package (`Modules/`) containing six modules:

- **Domain** — `Breed`, `LifeSpan`, `BreedRepository` and `FavouritesStore` protocols, error types. No platform dependencies.
- **Networking** — `CatAPIClient` against The Cat API and DTO mapping to Domain models.
- **Persistence** — `OfflineFirstBreedRepository` (concrete `BreedRepository`), `SwiftDataFavouritesStore` (concrete `FavouritesStore`), `BreedEntity` SwiftData model, and `PersistenceContainer` factory.
- **BreedsListFeature** — list screen with search and pagination.
- **BreedDetailFeature** — detail screen with image, fields, and favourite toggle.
- **FavouritesFeature** — favourites tab.

Feature modules depend only on `Domain` protocols. `Networking` and `Persistence` are wired together at the composition root in the iOS app target (`CatBreedsApp.swift`).

### Offline-first strategy

`OfflineFirstBreedRepository` always tries the network first. On success it writes the result through to the SwiftData cache and returns the fresh data. On failure (offline, timeout, server error, etc.) it falls back to reading from the cache. The favourites flag lives on the same SwiftData entity, so favouriting works offline.

### Search

Search hits the Cat API's `/breeds/search` endpoint, writes the results through to the SwiftData cache, and returns them. When the device is offline, it falls back to an in-memory `localizedCaseInsensitiveContains` filter over `name` and `temperament` from the cache.

## Setup

1. Copy `Secrets.xcconfig.example` to `Secrets.xcconfig` and set `CAT_API_KEY` to your Cat API key (free at https://thecatapi.com).
2. Open `CatBreeds/CatBreeds.xcodeproj`.
3. Build and run on an iOS 17.4+ simulator or device.

`Secrets.xcconfig` is gitignored.

## Tech choices

- SwiftUI with the `@Observable` macro for view models.
- SwiftData for persistence.
- Swift Concurrency (`async`/`await`, `actor`) — repositories and stores are actors so all I/O is isolated.
- No third-party dependencies.
- Tests live in `Modules/Tests/`, organised per module, and use Swift Testing (`@Test`, `#expect`).
