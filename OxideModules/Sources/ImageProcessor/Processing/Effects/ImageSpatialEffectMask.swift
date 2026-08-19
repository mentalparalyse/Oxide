import Foundation

public struct ImageSpatialEffectMask: Equatable, Codable, Sendable {
    public enum Mode: String, Codable, Sendable {
        case fullFrame
        case spot
    }

    public var mode: Mode
    public var centerX: Double
    public var centerY: Double
    public var radius: Double
    public var feather: Double

    public init(
        mode: Mode = .fullFrame,
        centerX: Double = 0.5,
        centerY: Double = 0.5,
        radius: Double = 0.35,
        feather: Double = 0.35
    ) {
        self.mode = mode
        self.centerX = Self.clamp(centerX)
        self.centerY = Self.clamp(centerY)
        self.radius = Self.clamp(radius, minimum: 0.05)
        self.feather = Self.clamp(feather)
    }

    public static let fullFrame = ImageSpatialEffectMask()

    private static func clamp(_ value: Double, minimum: Double = 0) -> Double {
        min(max(value, minimum), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case mode, centerX, centerY, radius, feather
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            mode: try container.decodeIfPresent(Mode.self, forKey: .mode) ?? .fullFrame,
            centerX: try container.decodeIfPresent(Double.self, forKey: .centerX) ?? 0.5,
            centerY: try container.decodeIfPresent(Double.self, forKey: .centerY) ?? 0.5,
            radius: try container.decodeIfPresent(Double.self, forKey: .radius) ?? 0.35,
            feather: try container.decodeIfPresent(Double.self, forKey: .feather) ?? 0.35
        )
    }
}
