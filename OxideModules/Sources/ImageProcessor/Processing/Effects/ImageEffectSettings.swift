import Foundation

public struct ImageFilmGrain: Equatable, Codable, Sendable {
    public var amount: Double
    public var size: Double
    public var seed: UInt32

    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        size: Double = 1,
        seed: UInt32 = 1
    ) {
        self.amount = Self.clamp(amount, to: 0...1)
        self.size = Self.clamp(size, to: 0.5...4)
        self.seed = seed
    }

    public static let disabled = ImageFilmGrain()

    private static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private enum CodingKeys: String, CodingKey {
        case amount
        case size
        case seed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            size: try container.decodeIfPresent(Double.self, forKey: .size) ?? 1,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1
        )
    }
}

public struct ImageEffects: Equatable, Codable, Sendable {
    public var filmGrain: ImageFilmGrain
    public var lightLeak: ImageLightLeak

    public init(
        filmGrain: ImageFilmGrain = .disabled,
        lightLeak: ImageLightLeak = .disabled
    ) {
        self.filmGrain = filmGrain
        self.lightLeak = lightLeak
    }

    public static let neutral = ImageEffects()

    private enum CodingKeys: String, CodingKey {
        case filmGrain
        case lightLeak
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filmGrain = try container.decodeIfPresent(
            ImageFilmGrain.self,
            forKey: .filmGrain
        ) ?? .disabled
        lightLeak = try container.decodeIfPresent(
            ImageLightLeak.self,
            forKey: .lightLeak
        ) ?? .disabled
    }
}

public struct ImageLightLeak: Equatable, Codable, Sendable {
    public var amount: Double
    public var position: Double
    public var warmth: Double
    public var seed: UInt32

    public init(
        amount: Double = 0,
        position: Double = 0.2,
        warmth: Double = 0.8,
        seed: UInt32 = 1
    ) {
        self.amount = Self.clamp(amount)
        self.position = Self.clamp(position)
        self.warmth = Self.clamp(warmth)
        self.seed = seed
    }

    public static let disabled = ImageLightLeak()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, position, warmth, seed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            position: try container.decodeIfPresent(Double.self, forKey: .position) ?? 0.2,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.8,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1
        )
    }
}
