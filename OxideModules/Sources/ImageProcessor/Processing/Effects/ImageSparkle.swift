import Foundation

public struct ImageSparkle: Equatable, Codable, Sendable {
    public var amount: Double
    public var threshold: Double
    public var rayLength: Double
    public var rotation: Double
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        threshold: Double = 0.72,
        rayLength: Double = 0.45,
        rotation: Double = 0,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.threshold = min(max(threshold, 0), 1)
        self.rayLength = min(max(rayLength, 0), 1)
        self.rotation = min(max(rotation, 0), 1)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageSparkle()

    private enum CodingKeys: String, CodingKey {
        case amount, threshold, rayLength, rotation, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            threshold: try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0.72,
            rayLength: try container.decodeIfPresent(Double.self, forKey: .rayLength) ?? 0.45,
            rotation: try container.decodeIfPresent(Double.self, forKey: .rotation) ?? 0,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
