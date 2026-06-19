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
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(isSelected ? AppColours.buttonBacground : Color.clear, lineWidth: 2)
                }
                
                Text(filter.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? AppColours.buttonBacground : AppColours.appMutedForegroundColor)
            }
        }
        .buttonStyle(.plain)
    }
}

struct LUTPreviewImage: View {
    let imageURL: URL?
    let presetID: String?
    var intensity: Double = 1.0
    let rotationDegrees: Int
    var crop: ImageEditCrop? = nil
    var adjustments: ImageAdjustments = .neutral
    let contentMode: ContentMode
    var maxPixelSize: CGFloat?
    
    @State private var renderedImage: UIImage?
    @State private var renderGeneration = 0
    private static let imageProcessor = ImageProcessor()
    
    var body: some View {
        Group {
            if let renderedImage {
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
        .task(id: taskID) {
            await renderAfterDebounce()
        }
    }
    
    private var taskID: String {
        let roundedIntensity = (intensity * 1_000).rounded() / 1_000
        return "\(imageURL?.absoluteString ?? "nil")-\(presetID ?? "original")-\(rotationDegrees)-\(roundedIntensity)-\(cropID)-\(adjustments)"
    }
    
    private var cropID: String {
        guard let crop else { return "no-crop" }
        return "\(crop.x)-\(crop.y)-\(crop.width)-\(crop.height)"
    }
    
    @MainActor
    private func renderAfterDebounce() async {
        guard let imageURL else {
            renderedImage = nil
            return
        }

        renderGeneration += 1
        let generation = renderGeneration

        do {
            try await Task.sleep(for: .milliseconds(50))
        } catch {
            return
        }

        guard !Task.isCancelled, generation == renderGeneration else {
            return
        }

        let image = await Self.imageProcessor.renderUIImage(
            from: imageURL,
            presetID: presetID,
            intensity: intensity,
            rotationDegrees: rotationDegrees,
            crop: crop,
            adjustments: adjustments,
            maxPixelSize: maxPixelSize
        )

        guard
            !Task.isCancelled,
            generation == renderGeneration,
            let image
        else {
            return
        }

        renderedImage = image
    }
}
