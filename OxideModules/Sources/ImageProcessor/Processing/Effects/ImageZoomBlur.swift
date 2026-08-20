import Foundation

public struct ImageZoomBlur: Equatable, Codable, Sendable {
    public var amount: Double
    public var strength: Double
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 && strength > 0 }

    public init(
        amount: Double = 0,
        strength: Double = 0.45,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.strength = min(max(strength, 0), 1)
        self.spatialMask = spatialMask
    }
    public static let disabled = ImageZoomBlur()

    private enum CodingKeys: String, CodingKey { case amount, strength, spatialMask }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            strength: try container.decodeIfPresent(Double.self, forKey: .strength) ?? 0.45,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
