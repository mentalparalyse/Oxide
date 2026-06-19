// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI

@MainActor
public enum GalleryBuilder {
    public static func build() -> some View {
        let interactor = GalleryInteractor()
        let router = GalleryRouter()
        let presenter = GalleryPresenter(interactor: interactor, router: router)
        return GalleryView(presenter: presenter)
    }
}

