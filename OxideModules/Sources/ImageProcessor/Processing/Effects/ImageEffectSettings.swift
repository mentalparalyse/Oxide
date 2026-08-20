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
    public var chromaticAberration: ImageChromaticAberration
    public var halation: ImageHalation
    public var dustAndScratches: ImageDustAndScratches
    public var bloom: ImageBloom
    public var vhs: ImageVHS

    public init(
        filmGrain: ImageFilmGrain = .disabled,
        lightLeak: ImageLightLeak = .disabled,
        chromaticAberration: ImageChromaticAberration = .disabled,
        halation: ImageHalation = .disabled,
        dustAndScratches: ImageDustAndScratches = .disabled,
        bloom: ImageBloom = .disabled,
        vhs: ImageVHS = .disabled
    ) {
        self.filmGrain = filmGrain
        self.lightLeak = lightLeak
        self.chromaticAberration = chromaticAberration
        self.halation = halation
        self.dustAndScratches = dustAndScratches
        self.bloom = bloom
        self.vhs = vhs
    }

    public static let neutral = ImageEffects()

    private enum CodingKeys: String, CodingKey {
        case filmGrain
        case lightLeak
        case chromaticAberration
        case halation
        case dustAndScratches
        case bloom
        case vhs
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
        chromaticAberration = try container.decodeIfPresent(
            ImageChromaticAberration.self,
            forKey: .chromaticAberration
        ) ?? .disabled
        halation = try container.decodeIfPresent(
            ImageHalation.self,
            forKey: .halation
        ) ?? .disabled
        dustAndScratches = try container.decodeIfPresent(
            ImageDustAndScratches.self,
            forKey: .dustAndScratches
        ) ?? .disabled
        bloom = try container.decodeIfPresent(
            ImageBloom.self,
            forKey: .bloom
        ) ?? .disabled
        vhs = try container.decodeIfPresent(
            ImageVHS.self,
            forKey: .vhs
        ) ?? .disabled
    }
}

public struct ImageDustAndScratches: Equatable, Codable, Sendable {
    public var amount: Double
    public var dustAmount: Double
    public var scratchAmount: Double
    public var particleSize: Double
    public var seed: UInt32

    public var isEnabled: Bool {
        amount > 0 && (dustAmount > 0 || scratchAmount > 0)
    }

    public init(
        amount: Double = 0,
        dustAmount: Double = 0.55,
        scratchAmount: Double = 0.2,
        particleSize: Double = 0.45,
        seed: UInt32 = 1
    ) {
        self.amount = Self.clamp(amount)
        self.dustAmount = Self.clamp(dustAmount)
        self.scratchAmount = Self.clamp(scratchAmount)
        self.particleSize = Self.clamp(particleSize)
        self.seed = seed
    }

    public static let disabled = ImageDustAndScratches()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, dustAmount, scratchAmount, particleSize, seed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            dustAmount: try container.decodeIfPresent(Double.self, forKey: .dustAmount) ?? 0.55,
            scratchAmount: try container.decodeIfPresent(Double.self, forKey: .scratchAmount) ?? 0.2,
            particleSize: try container.decodeIfPresent(Double.self, forKey: .particleSize) ?? 0.45,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1
        )
    }
}

public struct ImageHalation: Equatable, Codable, Sendable {
    public var amount: Double
    public var radius: Double
    public var threshold: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        radius: Double = 0.5,
        threshold: Double = 0.72,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.radius = Self.clamp(radius)
        self.threshold = Self.clamp(threshold)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageHalation()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, radius, threshold, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            radius: try container.decodeIfPresent(Double.self, forKey: .radius) ?? 0.5,
            threshold: try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0.72,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}

public struct ImageChromaticAberration: Equatable, Codable, Sendable {
    public var amount: Double
    public var direction: Double
    public var falloff: Double
    public var spatialMask: ImageSpatialEffectMask

    public init(
        amount: Double = 0,
        direction: Double = 0,
        falloff: Double = 0.55,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.direction = Self.clamp(direction)
        self.falloff = Self.clamp(falloff)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageChromaticAberration()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, direction, falloff, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            direction: try container.decodeIfPresent(Double.self, forKey: .direction) ?? 0,
            falloff: try container.decodeIfPresent(Double.self, forKey: .falloff) ?? 0.55,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}

public struct ImageLightLeak: Equatable, Codable, Sendable {
    public var amount: Double
    public var position: Double
    public var warmth: Double
    public var seed: UInt32
    public var spatialMask: ImageSpatialEffectMask

    public init(
        amount: Double = 0,
        position: Double = 0.2,
        warmth: Double = 0.8,
        seed: UInt32 = 1,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.position = Self.clamp(position)
        self.warmth = Self.clamp(warmth)
        self.seed = seed
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageLightLeak()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, position, warmth, seed, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            position: try container.decodeIfPresent(Double.self, forKey: .position) ?? 0.2,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.8,
            seed: try container.decodeIfPresent(UInt32.self, forKey: .seed) ?? 1,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
