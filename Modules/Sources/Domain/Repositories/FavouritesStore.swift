public protocol FavouritesStore: Sendable {
    func favouriteIDs() async throws -> Set<String>
    func setFavourite(_ isFavourite: Bool, for breedID: String) async throws
    var favouriteIDsStream: AsyncStream<Set<String>> { get }
}
