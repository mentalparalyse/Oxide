import Foundation

public struct ImageLensWarp: Equatable, Codable, Sendable {
    public var amount: Double
    public var scale: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && scale != 0 }

    public init(
        amount: Double = 0,
        scale: Double = 0.5,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount, to: 0...1)
        self.scale = Self.clamp(scale, to: -1...1)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageLensWarp()

    private static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, scale, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            scale: try container.decodeIfPresent(Double.self, forKey: .scale) ?? 0.5,
            spatialMask: try container.decodeIfPresent(
                ImageSpatialEffectMask.self,
                forKey: .spatialMask
            ) ?? .fullFrame
        )
    }
}
