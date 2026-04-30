import Domain

public protocol CatAPIClientProtocol: Sendable {
    func breeds(page: Int, limit: Int) async throws -> [Breed]
    func breed(id: String) async throws -> Breed
}
