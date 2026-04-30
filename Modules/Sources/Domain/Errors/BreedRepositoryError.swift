public enum BreedRepositoryError: Error, Equatable, Sendable {
    case offline
    case notFound
    case decoding
    case network(statusCode: Int)
    case unknown
}
