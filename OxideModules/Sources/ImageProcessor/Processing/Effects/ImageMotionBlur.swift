import Foundation

public struct ImageMotionBlur: Equatable, Codable, Sendable {
    public var amount: Double
    public var distance: Double
    public var angle: Double
    public var isEnabled: Bool { amount > 0 && distance > 0 }
    public init(amount: Double = 0, distance: Double = 0.4, angle: Double = 0) {
        self.amount = min(max(amount, 0), 1)
        self.distance = min(max(distance, 0), 1)
        self.angle = min(max(angle, 0), 1)
    }
    public static let disabled = ImageMotionBlur()
}
