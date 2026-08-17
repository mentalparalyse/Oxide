// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct PreviewActionButton: View {
    let systemName: String
    let title: String
    var foreground: Color = AppColours.appForegroundColor
    var background: Color = Color.white.opacity(0.1)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 48, height: 48)
                    .background(background, in: Circle())
                Text(title)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct CircleIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .frame(width: 40, height: 40)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct LastPhotoButton: View {
    let photo: GalleryPhoto?
    let action: () -> Void

    var body: some View {
        if let photo {
            Button(action: action) {
                GalleryThumbnailImage(
                    photo: photo,
                    maxPixelSize: 128
                )
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
        } else {
            Color.clear
        }
    }
}
