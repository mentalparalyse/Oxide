import Foundation

public struct ImageSunFlare: Equatable, Codable, Sendable {
    public var amount: Double
    public var size: Double
    public var rays: Double
    public var warmth: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && size > 0 }

    public init(
        amount: Double = 0,
        size: Double = 0.5,
        rays: Double = 0.5,
        warmth: Double = 0.65,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.size = Self.clamp(size)
        self.rays = Self.clamp(rays)
        self.warmth = Self.clamp(warmth)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageSunFlare()

    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }

    private enum CodingKeys: String, CodingKey { case amount, size, rays, warmth, spatialMask }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            size: try container.decodeIfPresent(Double.self, forKey: .size) ?? 0.5,
            rays: try container.decodeIfPresent(Double.self, forKey: .rays) ?? 0.5,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.65,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
