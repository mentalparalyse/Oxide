import Foundation

public struct ImageTiltShift: Equatable, Codable, Sendable {
    public enum Style: String, Codable, Sendable { case linear, radial }

    public var amount: Double
    public var blur: Double
    public var style: Style
    public var rotation: Double
    public var spatialMask: ImageSpatialEffectMask
    public var isEnabled: Bool { amount > 0 && blur > 0 }

    public init(
        amount: Double = 0,
        blur: Double = 0.55,
        style: Style = .linear,
        rotation: Double = 0,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = min(max(amount, 0), 1)
        self.blur = min(max(blur, 0), 1)
        self.style = style
        self.rotation = min(max(rotation, 0), 1)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageTiltShift()

    private enum CodingKeys: String, CodingKey {
        case amount, blur, style, rotation, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            blur: try container.decodeIfPresent(Double.self, forKey: .blur) ?? 0.55,
            style: try container.decodeIfPresent(Style.self, forKey: .style) ?? .linear,
            rotation: try container.decodeIfPresent(Double.self, forKey: .rotation) ?? 0,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
