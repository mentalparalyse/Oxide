// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import Foundation

public enum CameraAspectRatio: String, CaseIterable, Identifiable, Sendable {
    case fourThree = "4:3"
    case square = "1:1"
    case sixteenNine = "16:9"
    case full = "Full"

    public var id: String { rawValue }

    public var ratio: CGFloat? {
        switch self {
        case .fourThree: 4 / 3
        case .square: 1
        case .sixteenNine: 16 / 9
        case .full: nil
        }
    }
}
