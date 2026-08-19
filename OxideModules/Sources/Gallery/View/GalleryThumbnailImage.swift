// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIKit

struct GalleryThumbnailImage: View {
    let photo: GalleryPhoto
    let maxPixelSize: CGFloat

    @State private var image: UIImage?

    var body: some View {
        Group {
            if photo.imageURI.isFileURL {
                localImage
            } else {
                remoteImage
            }
        }
        .task(id: taskID) {
            guard photo.imageURI.isFileURL else { return }
            image = nil
            image = await ImagePreviewProvider.shared.preview(
                from: photo,
                maxPixelSize: maxPixelSize
            )
        }
    }

    @ViewBuilder
    private var localImage: some View {
        if let image {
            GeometryReader { proxy in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        } else {
            placeholder
        }
    }

    private var remoteImage: some View {
        GeometryReader { proxy in
            AsyncImage(url: photo.imageURI) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholder
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var placeholder: some View {
        Color.clear
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }

    private var taskID: String {
        let recipe = photo.imageEditRecipe
        return [
            photo.imageURI.absoluteString,
            String(Int(maxPixelSize)),
            recipe.presetID ?? "original",
            String(recipe.filterIntensity),
            String(recipe.rotationDegrees),
            String(describing: recipe.crop),
            String(describing: recipe.adjustments),
            String(describing: recipe.effects)
        ].joined(separator: "|")
    }
}
