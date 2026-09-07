import Foundation

public struct ImageBokeh: Equatable, Codable, Sendable {
    public var amount: Double; public var density: Double; public var size: Double
    public var softness: Double; public var warmth: Double; public var seed: UInt32
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 && density > 0 && size > 0 }
    public init(amount: Double = 0, density: Double = 0.45, size: Double = 0.5, softness: Double = 0.65, warmth: Double = 0.55, seed: UInt32 = 1, spatialMask: ImageSpatialEffectMask = .fullFrame) {
        self.amount = Self.clamp(amount); self.density = Self.clamp(density); self.size = Self.clamp(size)
        self.softness = Self.clamp(softness); self.warmth = Self.clamp(warmth); self.seed = seed; self.spatialMask = spatialMask
    }
    public static let disabled = ImageBokeh()
    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }
    private enum CodingKeys: String, CodingKey { case amount, density, size, softness, warmth, seed, spatialMask }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(amount: try c.decodeIfPresent(Double.self, forKey: .amount) ?? 0, density: try c.decodeIfPresent(Double.self, forKey: .density) ?? 0.45, size: try c.decodeIfPresent(Double.self, forKey: .size) ?? 0.5, softness: try c.decodeIfPresent(Double.self, forKey: .softness) ?? 0.65, warmth: try c.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.55, seed: try c.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1, spatialMask: try c.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame)
    }
}
