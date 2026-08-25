import Foundation

public struct ImageVignette: Equatable, Codable, Sendable {
    public struct Color: Equatable, Codable, Sendable {
        public var red: Double
        public var green: Double
        public var blue: Double

        public init(red: Double = 0, green: Double = 0, blue: Double = 0) {
            self.red = min(max(red, 0), 1)
            self.green = min(max(green, 0), 1)
            self.blue = min(max(blue, 0), 1)
        }

        public static let black = Color()
        public static let white = Color(red: 1, green: 1, blue: 1)
    }

    public var amount: Double
    public var size: Double
    public var feather: Double
    public var roundness: Double
    public var irregularity: Double
    public var color: Color
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        size: Double = 0.55,
        feather: Double = 0.65,
        roundness: Double = 0.5,
        irregularity: Double = 0,
        color: Color = .black,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.size = Self.clamp(size)
        self.feather = Self.clamp(feather)
        self.roundness = Self.clamp(roundness)
        self.irregularity = Self.clamp(irregularity)
        self.color = color
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageVignette()
    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }

    private enum CodingKeys: String, CodingKey {
        case amount, size, feather, roundness, irregularity, color, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            size: try container.decodeIfPresent(Double.self, forKey: .size) ?? 0.55,
            feather: try container.decodeIfPresent(Double.self, forKey: .feather) ?? 0.65,
            roundness: try container.decodeIfPresent(Double.self, forKey: .roundness) ?? 0.5,
            irregularity: try container.decodeIfPresent(Double.self, forKey: .irregularity) ?? 0,
            color: try container.decodeIfPresent(Color.self, forKey: .color) ?? .black,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
