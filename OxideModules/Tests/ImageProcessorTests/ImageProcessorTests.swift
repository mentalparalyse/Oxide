// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
import CoreImage
import Foundation
@testable import ImageProcessor

struct ImageProcessorTests {

    @Test func lutPresetsHaveStableUniqueIdentifiers() async throws {
        let ids = LUTFilterPreset.all.map(\.id)

        #expect(Set(ids).count == ids.count)
        #expect(ids.first == LUTFilterPreset.original.id)
    }

    @Test func bundledLUTPresetsAreLoadedFromFilterImgs2() async throws {
        let presets = LUTFilterPreset.bundledPresets

        #expect(presets.isEmpty == false)
        #expect(presets.count == 120)
        #expect(presets.contains { $0.id == "01_brooklyn" })
        #expect(presets.allSatisfy { $0.lutResourceName != nil })
    }

    @Test func numberedLUTPresetsUseThemedDisplayNames() async throws {
        let names = LUTFilterPreset.bundledPresets.map(\.name)

        #expect(names.contains("Cinematic 01"))
        #expect(names.contains("Vintage 01"))
        #expect(names.contains("Dream 03"))
        #expect(names.allSatisfy { !$0.localizedCaseInsensitiveContains("loot") })
    }

    @Test func bundledLUTResourcesResolveByNameWithoutDirectoryEnumeration() async throws {
        let resourceURL = LUTFilterPreset.bundledResourceURL(for: "01_brooklyn")

        #expect(resourceURL != nil)
    }

    @Test func generatedLookupImageHasExpectedHaldSize() async throws {
        let image = try #require(LUTImageFactory.makeLookupImage(for: LUTFilterPreset.all[1]))

        #expect(image.extent.width == 512)
        #expect(image.extent.height == 512)
    }

    @Test func originalPresetUsesZeroIntensity() async throws {
        #expect(LUTFilterPreset.original.intensity == 0)
    }

    @Test func generatedLookupImageBuildsColorCubeData() async throws {
        let image = try #require(LUTImageFactory.makeLookupImage(for: LUTFilterPreset.all[1]))
        let context = CIContext()
        let cubeData = try #require(LUTColorCubeFactory.makeCubeData(from: image, context: context))
        let expectedByteCount = 64 * 64 * 64 * 4 * MemoryLayout<Float>.size

        #expect(cubeData.count == expectedByteCount)
    }

    @Test func neutralAdjustmentsPreserveImageExtent() {
        let input = CIImage(
            color: CIColor(red: 0.2, green: 0.4, blue: 0.6)
        )
        .cropped(to: CGRect(x: 0, y: 0, width: 10, height: 20))

        let output = ImageAdjustmentFilter.apply(
            to: input,
            adjustments: .neutral
        )

        #expect(output.extent == input.extent)
    }

    @Test func adjustmentFilterSupportsCombinedControls() {
        let input = CIImage(
            color: CIColor(red: 0.2, green: 0.4, blue: 0.6)
        )
        .cropped(to: CGRect(x: 0, y: 0, width: 10, height: 20))
        let adjustments = ImageAdjustments(
            exposure: 1,
            contrast: 1.2,
            saturation: 0.8,
            brightness: 0.1,
            isMonochrome: true
        )

        let output = ImageAdjustmentFilter.apply(
            to: input,
            adjustments: adjustments
        )

        #expect(output.extent == input.extent)
    }

    @Test func processPersistenceRecordsAndUndoesSnapshots() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let persistence = ImageProcessPersistence<TestSnapshot>(rootDirectory: rootDirectory)

        persistence.resetHistory(for: "photo")
        _ = persistence.record(TestSnapshot(id: "original", value: 0), identifier: "photo")
        _ = persistence.record(TestSnapshot(id: "edited", value: 1), identifier: "photo")
        let undoState = persistence.undo()

        #expect(undoState.currentSnapshot == TestSnapshot(id: "original", value: 0))
        #expect(undoState.canUndo == false)

        try? FileManager.default.removeItem(at: rootDirectory)
    }

    @Test func processPersistencePrunesRedoSnapshotsAfterNewRecord() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let persistence = ImageProcessPersistence<TestSnapshot>(rootDirectory: rootDirectory)

        persistence.resetHistory(for: "photo")
        _ = persistence.record(TestSnapshot(id: "original", value: 0), identifier: "photo")
        _ = persistence.record(TestSnapshot(id: "first", value: 1), identifier: "photo")
        _ = persistence.record(TestSnapshot(id: "second", value: 2), identifier: "photo")
        _ = persistence.undo()
        _ = persistence.record(TestSnapshot(id: "replacement", value: 3), identifier: "photo")
        let undoState = persistence.undo()

        #expect(undoState.currentSnapshot == TestSnapshot(id: "first", value: 1))

        try? FileManager.default.removeItem(at: rootDirectory)
    }

    @Test func centeredCropReducesWiderSourceWidth() async throws {
        let crop = try #require(ImageEditCropper.centeredCrop(
            sourceSize: CGSize(width: 4000, height: 3000),
            aspectRatio: 1
        ))

        #expect(abs(crop.x - 0.125) < 0.001)
        #expect(crop.y == 0)
        #expect(abs(crop.width - 0.75) < 0.001)
        #expect(crop.height == 1)
    }

    @Test func centeredCropReducesTallerSourceHeight() async throws {
        let crop = try #require(ImageEditCropper.centeredCrop(
            sourceSize: CGSize(width: 3000, height: 4000),
            aspectRatio: 1
        ))

        #expect(crop.x == 0)
        #expect(abs(crop.y - 0.125) < 0.001)
        #expect(crop.width == 1)
        #expect(abs(crop.height - 0.75) < 0.001)
    }

    @Test func rotationNormalizesNegativeAndOverflowDegrees() async throws {
        #expect(ImageEditRotation.normalized(-90) == 270)
        #expect(ImageEditRotation.normalized(450) == 90)
        #expect(ImageEditRotation.normalized(720) == 0)
    }

    @Test func cropResizeMovesLeadingEdgeAndClampsMinimumWidth() async throws {
        let crop = ImageEditCrop(x: 0.1, y: 0.2, width: 0.5, height: 0.6)

        let resized = ImageEditCropper.resized(
            crop,
            edge: .leading,
            horizontalDelta: 0.2,
            verticalDelta: 0
        )
        let clamped = ImageEditCropper.resized(
            crop,
            edge: .leading,
            horizontalDelta: 0.8,
            verticalDelta: 0
        )

        #expect(abs(resized.x - 0.3) < 0.001)
        #expect(abs(resized.width - 0.3) < 0.001)
        #expect(abs(clamped.width - ImageEditCropper.minimumSide) < 0.001)
        #expect(abs(clamped.x - (0.6 - ImageEditCropper.minimumSide)) < 0.001)
    }

    @Test func cropResizeMovesBottomEdgeAndClampsToImageBounds() async throws {
        let crop = ImageEditCrop(x: 0.1, y: 0.2, width: 0.5, height: 0.6)

        let resized = ImageEditCropper.resized(
            crop,
            edge: .bottom,
            horizontalDelta: 0,
            verticalDelta: 0.5
        )

        #expect(resized.y == crop.y)
        #expect(resized.height == 0.8)
    }

}

private struct TestSnapshot: Codable, Equatable, Sendable {
    let id: String
    let value: Int
}
