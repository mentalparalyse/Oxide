import Foundation

public struct ImagePixelSort: Equatable, Codable, Sendable {
    public var amount: Double
    public var threshold: Double
    public var trailLength: Double
    public var direction: Double
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 && trailLength > 0 }

    public init(
        amount: Double = 0,
        threshold: Double = 0.58,
        trailLength: Double = 0.5,
        direction: Double = 0.25,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.threshold = min(max(threshold, 0), 1)
        self.trailLength = min(max(trailLength, 0), 1)
        self.direction = min(max(direction, 0), 1)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImagePixelSort()

    private enum CodingKeys: String, CodingKey {
        case amount, threshold, trailLength, direction, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            threshold: try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0.58,
            trailLength: try container.decodeIfPresent(Double.self, forKey: .trailLength) ?? 0.5,
            direction: try container.decodeIfPresent(Double.self, forKey: .direction) ?? 0.25,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
