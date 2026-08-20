import Foundation

public struct ImageVHS: Equatable, Codable, Sendable {
    public var amount: Double
    public var distortion: Double
    public var scanlines: Double
    public var colorBleed: Double
    public var seed: UInt32

    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        distortion: Double = 0.35,
        scanlines: Double = 0.45,
        colorBleed: Double = 0.4,
        seed: UInt32 = 1
    ) {
        self.amount = Self.clamp(amount)
        self.distortion = Self.clamp(distortion)
        self.scanlines = Self.clamp(scanlines)
        self.colorBleed = Self.clamp(colorBleed)
        self.seed = seed
    }

    public static let disabled = ImageVHS()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, distortion, scanlines, colorBleed, seed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            distortion: try container.decodeIfPresent(Double.self, forKey: .distortion) ?? 0.35,
            scanlines: try container.decodeIfPresent(Double.self, forKey: .scanlines) ?? 0.45,
            colorBleed: try container.decodeIfPresent(Double.self, forKey: .colorBleed) ?? 0.4,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1
        )
    }
}
