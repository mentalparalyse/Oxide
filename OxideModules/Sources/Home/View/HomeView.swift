// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Gallery
import SwiftUI

public enum Tab: Equatable {
    case gallery
    case settings
}

public struct HomeView: View {
    @StateObject var presenter: HomePresenter

    public init(presenter: HomePresenter) {
        self._presenter = StateObject(wrappedValue: presenter)
    }

    public var body: some View {
        GalleryBuilder
            .build()
            .navigationBarStyle(.default)
    }
}
