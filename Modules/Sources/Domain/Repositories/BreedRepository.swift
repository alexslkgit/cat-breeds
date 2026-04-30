public protocol BreedRepository: Sendable {
    func breeds(page: Int, limit: Int) async throws -> [Breed]
    func breed(id: String) async throws -> Breed
}
