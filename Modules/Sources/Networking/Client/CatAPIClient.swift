import Foundation
import Domain

public final class CatAPIClient: CatAPIClientProtocol {
    private let session: URLSession
    private let apiKey: String
    private let baseURL = URL(string: "https://api.thecatapi.com/v1")!

    public init(session: URLSession = .shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    public func breeds(page: Int, limit: Int) async throws -> [Breed] {
        var components = URLComponents(url: baseURL.appendingPathComponent("breeds"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "page", value: String(page)),
        ]
        let dtos: [BreedDTO] = try await perform(request(for: components.url!))
        return dtos.map { $0.toDomain() }
    }

    public func breed(id: String) async throws -> Breed {
        let url = baseURL.appendingPathComponent("breeds").appendingPathComponent(id)
        let dto: BreedDTO = try await perform(request(for: url))
        return dto.toDomain()
    }

    private func request(for url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        return req
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .timedOut {
            throw BreedRepositoryError.offline
        } catch {
            throw BreedRepositoryError.unknown
        }
        guard let http = response as? HTTPURLResponse else {
            throw BreedRepositoryError.unknown
        }
        switch http.statusCode {
        case 200..<300:
            break
        case 404:
            throw BreedRepositoryError.notFound
        default:
            throw BreedRepositoryError.network(statusCode: http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch is DecodingError {
            throw BreedRepositoryError.decoding
        }
    }
}
