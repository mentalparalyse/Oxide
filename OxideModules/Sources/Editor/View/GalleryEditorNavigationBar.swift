// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryEditorNavigationBar: View {
    let canUndo: Bool
    let onCancel: () -> Void
    let onUndo: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack {
            EditorCircleIconButton(systemName: "xmark", label: "Cancel", action: onCancel)
            EditorCircleIconButton(systemName: "arrow.uturn.backward", label: "Undo last edit", action: onUndo)
                .opacity(canUndo ? 1 : 0.35)
                .disabled(!canUndo)

            Spacer()

            Button("Save", action: onSave)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .padding(.horizontal, 24)
                .frame(minHeight: 44)
                .background(AppColours.accent, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background {
            LinearGradient(
                colors: [AppColours.appColor.opacity(0.82), AppColours.appColor.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        }
    }
}

private struct EditorCircleIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 44, height: 44)
                .background(AppColours.appSurfaceColor, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColours.appForegroundColor)
        .accessibilityLabel(label)
    }
}
