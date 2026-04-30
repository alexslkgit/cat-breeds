//
//  BreedRepositoryError.swift
//  Domain
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

public enum BreedRepositoryError: Error, Equatable, Sendable {
    case offline
    case notFound
    case decoding
    case network(statusCode: Int)
    case unknown
}

extension BreedRepositoryError {
    private static let offlineMessage = "You appear to be offline."
    private static let notFoundMessage = "Breed not found."
    private static let decodingMessage = "Could not read response."
    private static let unknownMessage = "Something went wrong."

    public var displayMessage: String {
        switch self {
        case .offline: return Self.offlineMessage
        case .notFound: return Self.notFoundMessage
        case .decoding: return Self.decodingMessage
        case .network(let status): return "Network error (\(status))."
        case .unknown: return Self.unknownMessage
        }
    }

    public static func displayMessage(for error: Error) -> String {
        (error as? Self)?.displayMessage ?? error.localizedDescription
    }
}
