// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import ImageProcessor
import Testing
@testable import Gallery

struct GalleryPhotoResolutionTests {
    @Test func unchangedPhotoPreservesSourceDimensions() {
        let dimensions = GalleryPhotoResolution.editedDimensions(
            from: CGSize(width: 4_032, height: 3_024),
            crop: nil,
            rotationDegrees: 0
        )

        #expect(dimensions == GalleryPixelDimensions(width: 4_032, height: 3_024))
        #expect(dimensions?.formatted == "4032 × 3024 px")
    }

    @Test func cropAndQuarterTurnProduceExportDimensions() {
        let dimensions = GalleryPhotoResolution.editedDimensions(
            from: CGSize(width: 4_000, height: 3_000),
            crop: ImageEditCrop(x: 0.1, y: 0, width: 0.75, height: 0.5),
            rotationDegrees: 90
        )

        #expect(dimensions == GalleryPixelDimensions(width: 1_500, height: 3_000))
    }

    @Test func negativeQuarterTurnAlsoSwapsDimensions() {
        let dimensions = GalleryPhotoResolution.editedDimensions(
            from: CGSize(width: 1_920, height: 1_080),
            crop: nil,
            rotationDegrees: -90
        )

        #expect(dimensions == GalleryPixelDimensions(width: 1_080, height: 1_920))
    }

    @Test func missingOrInvalidSourceDimensionsAreUnavailable() {
        #expect(GalleryPhotoResolution.originalDimensions(from: nil) == nil)
        #expect(GalleryPhotoResolution.originalDimensions(from: .zero) == nil)
        #expect(
            GalleryPhotoResolution.editedDimensions(
                from: CGSize(width: CGFloat.infinity, height: 100),
                crop: nil,
                rotationDegrees: 0
            ) == nil
        )
    }

    @Test func cropDimensionsRoundToWholePixelsAndNeverReachZero() {
        let dimensions = GalleryPhotoResolution.editedDimensions(
            from: CGSize(width: 101, height: 51),
            crop: ImageEditCrop(x: 0, y: 0, width: 0.5, height: 0.01),
            rotationDegrees: 0
        )

        #expect(dimensions == GalleryPixelDimensions(width: 51, height: 1))
    }
}
