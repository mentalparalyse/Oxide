import Foundation

public struct ImageHaze: Equatable, Codable, Sendable {
    public var amount: Double
    public var density: Double
    public var depth: Double
    public var warmth: Double

    public var isEnabled: Bool { amount > 0 && density > 0 }

    public init(amount: Double = 0, density: Double = 0.45, depth: Double = 0.6, warmth: Double = 0.5) {
        self.amount = Self.clamp(amount)
        self.density = Self.clamp(density)
        self.depth = Self.clamp(depth)
        self.warmth = Self.clamp(warmth)
    }

    public static let disabled = ImageHaze()

    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }
    private enum CodingKeys: String, CodingKey { case amount, density, depth, warmth }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            density: try container.decodeIfPresent(Double.self, forKey: .density) ?? 0.45,
            depth: try container.decodeIfPresent(Double.self, forKey: .depth) ?? 0.6,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.5
        )
    }
}
