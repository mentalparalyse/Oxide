import Foundation

public struct ImageSoftFocus: Equatable, Codable, Sendable {
    public var amount: Double
    public var softness: Double
    public var glow: Double
    public var detail: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && softness > 0 }

    public init(
        amount: Double = 0,
        softness: Double = 0.5,
        glow: Double = 0.35,
        detail: Double = 0.65,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.softness = Self.clamp(softness)
        self.glow = Self.clamp(glow)
        self.detail = Self.clamp(detail)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageSoftFocus()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, softness, glow, detail, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            softness: try container.decodeIfPresent(Double.self, forKey: .softness) ?? 0.5,
            glow: try container.decodeIfPresent(Double.self, forKey: .glow) ?? 0.35,
            detail: try container.decodeIfPresent(Double.self, forKey: .detail) ?? 0.65,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
