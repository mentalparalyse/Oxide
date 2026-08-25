// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

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
