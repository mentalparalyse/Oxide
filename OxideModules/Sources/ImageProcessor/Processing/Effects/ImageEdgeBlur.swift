import Foundation

public struct ImageEdgeBlur: Equatable, Codable, Sendable {
    public enum Shape: String, Codable, Sendable { case oval, frame }

    public var amount: Double
    public var blur: Double
    public var shape: Shape
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 && blur > 0 }

    public init(
        amount: Double = 0,
        blur: Double = 0.55,
        shape: Shape = .oval,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.blur = min(max(blur, 0), 1)
        self.shape = shape
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageEdgeBlur()

    private enum CodingKeys: String, CodingKey { case amount, blur, shape, spatialMask }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            blur: try container.decodeIfPresent(Double.self, forKey: .blur) ?? 0.55,
            shape: try container.decodeIfPresent(Shape.self, forKey: .shape) ?? .oval,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
