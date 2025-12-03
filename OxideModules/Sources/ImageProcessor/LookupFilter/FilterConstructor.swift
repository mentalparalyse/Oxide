// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage

public final class FilterConstructor: NSObject, CIFilterConstructor {
    public func filter(withName name: String) -> CIFilter? {
        switch name {
        case "LookupFilter":
            return LookupFilter()
        default:
            return nil
        }
    }
}
