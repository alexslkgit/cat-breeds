import Foundation

public struct LifeSpan: Hashable, Sendable {
    public let minYears: Int
    public let maxYears: Int

    public init(minYears: Int, maxYears: Int) {
        self.minYears = minYears
        self.maxYears = maxYears
    }

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed
            .components(separatedBy: "-")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        switch parts.count {
        case 1:
            guard let value = Int(parts[0]) else { return nil }
            self.minYears = value
            self.maxYears = value
        case 2:
            guard !parts[0].isEmpty, !parts[1].isEmpty,
                  let lower = Int(parts[0]), let upper = Int(parts[1]) else { return nil }
            self.minYears = lower
            self.maxYears = upper
        default:
            return nil
        }
    }

    public var upperBound: Int { maxYears }

    public var average: Double { Double(minYears + maxYears) / 2.0 }
}
