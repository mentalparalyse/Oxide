// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryFloatingControls<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background {
                if reduceTransparency {
                    AppColours.appSurfaceColor
                } else {
                    Rectangle().fill(.ultraThinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        AppColours.appForegroundColor.opacity(colorSchemeContrast == .increased ? 0.42 : 0.14),
                        lineWidth: colorSchemeContrast == .increased ? 1.5 : 1
                    )
            }
            .shadow(color: .black.opacity(0.28), radius: 14, y: 6)
    }
}
