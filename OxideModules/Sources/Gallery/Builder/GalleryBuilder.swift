// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

@MainActor
public enum GalleryBuilder {
    public static func build(analytics: any AppAnalyticsTracking) -> some View {
        GalleryView(presenter: makePresenter(analytics: analytics))
    }

    public static func makePresenter(analytics: any AppAnalyticsTracking) -> GalleryPresenter {
        let interactor = GalleryInteractor()
        let router = GalleryRouter()
        return GalleryPresenter(interactor: interactor, router: router, analytics: analytics)
    }
}
