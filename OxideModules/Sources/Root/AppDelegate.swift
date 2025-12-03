// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import ImageProcessor
import UIKit

public final class AppDelegate: NSObject, UIApplicationDelegate {
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerLookupFilter()
        return true
    }

    
    private func registerLookupFilter() {
        CIFilter.registerName(
            "LookupFilter",
            constructor: FilterConstructor(),
            classAttributes: [kCIAttributeFilterCategories: ["CustomFilters"]]
        )
    }
}
