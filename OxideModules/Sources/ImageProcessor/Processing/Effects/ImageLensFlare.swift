import Foundation

public struct ImageLensFlare: Equatable, Codable, Sendable {
    public var amount: Double
    public var size: Double
    public var streak: Double
    public var warmth: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && size > 0 }

    public init(
        amount: Double = 0,
        size: Double = 0.5,
        streak: Double = 0.35,
        warmth: Double = 0.55,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.size = Self.clamp(size)
        self.streak = Self.clamp(streak)
        self.warmth = Self.clamp(warmth)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageLensFlare()

    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }

    private enum CodingKeys: String, CodingKey { case amount, size, streak, warmth, spatialMask }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            size: try container.decodeIfPresent(Double.self, forKey: .size) ?? 0.5,
            streak: try container.decodeIfPresent(Double.self, forKey: .streak) ?? 0.35,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.55,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
