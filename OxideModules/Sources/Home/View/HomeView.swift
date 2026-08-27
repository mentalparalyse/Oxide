// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Gallery
import SwiftUI

public enum Tab: Equatable {
    case gallery
    case settings
}

public struct HomeView: View {
    @StateObject var presenter: HomePresenter
    private let galleryPresenter: GalleryPresenter

    public init(presenter: HomePresenter, galleryPresenter: GalleryPresenter) {
        self._presenter = StateObject(wrappedValue: presenter)
        self.galleryPresenter = galleryPresenter
    }

    public var body: some View {
        GalleryView(presenter: galleryPresenter)
            .navigationBarStyle(.default)
    }
}
