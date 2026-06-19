// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage

/// Immutable ownership wrapper for sharing a reusable Core Image context across
/// Swift concurrency domains. Core Image contexts are designed for reuse, but
/// older SDKs do not declare `CIContext` as `Sendable`.
final class SendableCIContext: @unchecked Sendable {
    let value: CIContext

    init(_ value: CIContext) {
        self.value = value
    }

    convenience init(options: [CIContextOption: Any]) {
        self.init(CIContext(options: options))
    }
}
