import Foundation

public struct ImageKaleidoscope: Equatable, Codable, Sendable {
    public var amount: Double
    public var segments: Int
    public var rotation: Double
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        segments: Int = 6,
        rotation: Double = 0,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.segments = min(max(segments, 2), 12)
        self.rotation = min(max(rotation, 0), 1)
        self.spatialMask = spatialMask
    }
    public static let disabled = ImageKaleidoscope()

    private enum CodingKeys: String, CodingKey { case amount, segments, rotation, spatialMask }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            segments: try container.decodeIfPresent(Int.self, forKey: .segments) ?? 6,
            rotation: try container.decodeIfPresent(Double.self, forKey: .rotation) ?? 0,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
