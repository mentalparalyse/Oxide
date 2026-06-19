// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

public enum CameraAuthorizationState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
