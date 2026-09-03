import Foundation

public struct ImageLensDirt: Equatable, Codable, Sendable {
    public var amount: Double
    public var density: Double
    public var smudge: Double
    public var flare: Double
    public var seed: UInt32
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && (density > 0 || smudge > 0 || flare > 0) }

    public init(
        amount: Double = 0,
        density: Double = 0.45,
        smudge: Double = 0.35,
        flare: Double = 0.25,
        seed: UInt32 = 1,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.density = Self.clamp(density)
        self.smudge = Self.clamp(smudge)
        self.flare = Self.clamp(flare)
        self.seed = seed
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageLensDirt()
    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }

    private enum CodingKeys: String, CodingKey {
        case amount, density, smudge, flare, seed, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            density: try container.decodeIfPresent(Double.self, forKey: .density) ?? 0.45,
            smudge: try container.decodeIfPresent(Double.self, forKey: .smudge) ?? 0.35,
            flare: try container.decodeIfPresent(Double.self, forKey: .flare) ?? 0.25,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
