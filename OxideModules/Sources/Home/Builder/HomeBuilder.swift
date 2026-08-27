// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import Gallery
import SwiftUI

@MainActor
public enum HomeBuilder {
    public static func build(coordinator: any RootCoordinatorProtocol, analytics: any AppAnalyticsTracking) -> some View {
        let interactor = HomeInteractor()
        let router = HomeRouter(coordinator: coordinator)
        let presenter = HomePresenter(interactor: interactor, router: router)
        let galleryPresenter = GalleryBuilder.makePresenter(analytics: analytics)
        return HomeView(presenter: presenter, galleryPresenter: galleryPresenter)
    }
}
