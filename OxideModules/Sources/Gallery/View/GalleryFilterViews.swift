// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIComponents
import UIKit

struct FilterChipView: View {
    let filter: GalleryFilter
    let isSelected: Bool
    let imageURL: URL?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                LUTPreviewImage(
                    imageURL: imageURL,
                    presetID: filter.id,
                    rotationDegrees: 0,
                    contentMode: .fill,
                    maxPixelSize: 128
                )
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? AppColours.accent : Color.clear, lineWidth: 2)
                }
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(AppColours.accent, in: Circle())
                            .offset(x: 4, y: -4)
                    }
                }
                
                Text(filter.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? AppColours.accent : AppColours.appMutedForegroundColor)
            }
        }
        .buttonStyle(.plain)
    }
}

struct LUTPreviewImage: View {
    let imageURL: URL?
    let presetID: String?
    var intensity: Double = 0.5
    let rotationDegrees: Int
    var crop: ImageEditCrop? = nil
    var adjustments: ImageAdjustments = .neutral
    var effects: ImageEffects = .neutral
    let contentMode: ContentMode
    var maxPixelSize: CGFloat?
    
    @StateObject private var renderCoordinator = LUTPreviewRenderCoordinator()
    
    var body: some View {
        Group {
            if let renderedImage = renderCoordinator.image {
                Image(uiImage: renderedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                AppColours.appSurfaceColor
                    .overlay {
                        ProgressView()
                            .tint(AppColours.appMutedForegroundColor)
                    }
            }
        }
        .clipped()
        .onAppear { renderCoordinator.submit(renderRequest) }
        .onDisappear { renderCoordinator.cancel() }
        .onChange(of: renderRequest) { renderCoordinator.submit($0) }
    }

    private var renderRequest: LUTPreviewRenderRequest {
        LUTPreviewRenderRequest(
            imageURL: imageURL,
            presetID: presetID,
            intensity: intensity,
            rotationDegrees: rotationDegrees,
            crop: crop,
            adjustments: adjustments,
            effects: effects,
            maxPixelSize: maxPixelSize
        )
    }
}
