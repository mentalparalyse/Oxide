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
        Group {
            if reduceTransparency {
                opaqueSurface
            } else {
                transparentSurface
            }
        }
            .overlay {
                panelShape
                    .stroke(
                        AppColours.appForegroundColor.opacity(colorSchemeContrast == .increased ? 0.42 : 0.14),
                        lineWidth: colorSchemeContrast == .increased ? 1.5 : 1
                    )
            }
            .shadow(color: .black.opacity(0.28), radius: 14, y: 6)
    }

    private var panelShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    private var opaqueSurface: some View {
        content
            .background(AppColours.appSurfaceColor)
            .clipShape(panelShape)
    }

    @ViewBuilder
    private var transparentSurface: some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            liquidGlassSurface
        } else {
            materialSurface
        }
#else
        materialSurface
#endif
    }

#if compiler(>=6.2)
    @available(iOS 26.0, *)
    private var liquidGlassSurface: some View {
        content
            .background(AppColours.appColor.opacity(0.72), in: panelShape)
            .glassEffect(
                .regular
                    .tint(AppColours.appColor.opacity(0.72))
                    .interactive(),
                in: panelShape
            )
    }
#endif

    private var materialSurface: some View {
        content
            .background {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    AppColours.appColor.opacity(0.76)
                }
            }
            .clipShape(panelShape)
    }
}
