// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
import CoreImage
import Foundation
import UIKit
@testable import ImageProcessor

struct ImageProcessorTests {

    @Test func lutPresetsHaveStableUniqueIdentifiers() async throws {
        let ids = LUTFilterPreset.all.map(\.id)

        #expect(Set(ids).count == ids.count)
        #expect(ids.first == LUTFilterPreset.original.id)
    }

    @Test func publicDemoPresetsDoNotRequirePrivateResources() {
        #expect(LUTFilterPreset.demoPresets.isEmpty == false)
        #expect(LUTFilterPreset.demoPresets.allSatisfy { $0.lutResourceName == nil })
        #expect(LUTFilterPreset.all.starts(with: [.original] + LUTFilterPreset.demoPresets))
    }

    @Test func bundledLUTPresetsOnlyExposeAvailableResources() async throws {
        let presets = LUTFilterPreset.bundledPresets

        #expect(presets.allSatisfy { $0.lutResourceName != nil })
        #expect(presets.allSatisfy {
            guard let resourceName = $0.lutResourceName else { return false }
            return LUTFilterPreset.bundledResourceURL(for: resourceName) != nil
        })
    }

    @Test func numberedLUTPresetsUseThemedDisplayNames() async throws {
        let names = LUTFilterPreset.bundledResourceNames.map {
            LUTFilterPreset.displayName(for: $0)
        }

        #expect(names.contains("Cinematic 01"))
        #expect(names.contains("Vintage 01"))
        #expect(names.contains("Dream 03"))
        #expect(names.allSatisfy { !$0.localizedCaseInsensitiveContains("loot") })
    }

    @Test func missingLUTResourceIsNotExposed() async throws {
        let resourceURL = LUTFilterPreset.bundledResourceURL(for: "missing-resource")

        #expect(resourceURL == nil)
    }

    @Test func generatedLookupImageHasExpectedHaldSize() async throws {
        let preset = LUTFilterPreset(id: "cinematic", name: "Cinematic")
        let image = try #require(LUTImageFactory.makeLookupImage(for: preset))

        #expect(image.extent.width == 512)
        #expect(image.extent.height == 512)
    }

    @Test func originalPresetUsesZeroIntensity() async throws {
        #expect(LUTFilterPreset.original.intensity == 0)
    }

    @Test func generatedLookupImageBuildsColorCubeData() async throws {
        let preset = LUTFilterPreset(id: "cinematic", name: "Cinematic")
        let image = try #require(LUTImageFactory.makeLookupImage(for: preset))
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
        let persistence = ImageEditHistoryPersistence<TestSnapshot>(rootDirectory: rootDirectory)

        await persistence.resetHistory(for: "photo")
        _ = await persistence.record(TestSnapshot(id: "original", value: 0), identifier: "photo")
        _ = await persistence.record(TestSnapshot(id: "edited", value: 1), identifier: "photo")
        let undoState = await persistence.undo()

        #expect(undoState.currentSnapshot == TestSnapshot(id: "original", value: 0))
        #expect(undoState.canUndo == false)

        try? FileManager.default.removeItem(at: rootDirectory)
    }

    @Test func processPersistencePrunesRedoSnapshotsAfterNewRecord() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let persistence = ImageEditHistoryPersistence<TestSnapshot>(rootDirectory: rootDirectory)

        await persistence.resetHistory(for: "photo")
        _ = await persistence.record(TestSnapshot(id: "original", value: 0), identifier: "photo")
        _ = await persistence.record(TestSnapshot(id: "first", value: 1), identifier: "photo")
        _ = await persistence.record(TestSnapshot(id: "second", value: 2), identifier: "photo")
        _ = await persistence.undo()
        _ = await persistence.record(TestSnapshot(id: "replacement", value: 3), identifier: "photo")
        let undoState = await persistence.undo()

        #expect(undoState.currentSnapshot == TestSnapshot(id: "first", value: 1))

        try? FileManager.default.removeItem(at: rootDirectory)
    }

    @Test func defaultHistoryStoresIsolateMatchingIdentifiers() async {
        let first = ImageEditHistoryPersistence<TestSnapshot>()
        let second = ImageEditHistoryPersistence<TestSnapshot>()

        await first.resetHistory(for: "shared-photo")
        _ = await first.record(TestSnapshot(id: "first-original", value: 0), identifier: "shared-photo")
        _ = await first.record(TestSnapshot(id: "first-edit", value: 1), identifier: "shared-photo")

        await second.resetHistory(for: "shared-photo")
        _ = await second.record(TestSnapshot(id: "second-original", value: 10), identifier: "shared-photo")

        let firstUndo = await first.undo()
        let secondState = await second.undo()

        #expect(firstUndo.currentSnapshot == TestSnapshot(id: "first-original", value: 0))
        #expect(secondState.currentSnapshot == TestSnapshot(id: "second-original", value: 10))
    }

    @Test func imageFileStoreCreatesDirectoryAndWritesJPEG() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = ImageFileStore(rootDirectory: rootDirectory)
        let image = makeSolidImage(size: CGSize(width: 12, height: 8), color: .blue)
        let data = try #require(image.pngData())
        defer { try? FileManager.default.removeItem(at: rootDirectory) }

        let url = try await store.writeImageData(data, id: "photo")
        let storedImage = try #require(UIImage(data: Data(contentsOf: url)))

        #expect(url == rootDirectory.appendingPathComponent("photo.jpg"))
        #expect(storedImage.size == CGSize(width: 12, height: 8))
    }

    @Test func imageFileStorePreservesUnrecognizedDataWhenNormalizationIsUnavailable() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = ImageFileStore(rootDirectory: rootDirectory)
        let data = Data([0x01, 0x02, 0x03])
        defer { try? FileManager.default.removeItem(at: rootDirectory) }

        let url = try await store.writeImageData(data, id: "raw")

        #expect(try Data(contentsOf: url) == data)
    }

    @Test func exportServiceAcceptsClientOwnedSourceModel() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceURL = rootDirectory.appendingPathComponent("source.png")
        let outputDirectory = rootDirectory.appendingPathComponent("exports", isDirectory: true)
        try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let image = makeSolidImage(size: CGSize(width: 80, height: 40), color: .orange)
        try #require(image.pngData()).write(to: sourceURL, options: .atomic)
        let source = TestProcessingSource(
            imageSourceURL: sourceURL,
            imageEditRecipe: ImageEditRecipe(
                rotationDegrees: 90,
                crop: ImageEditCrop(x: 0, y: 0, width: 0.75, height: 1)
            )
        )

        let url = try await ImageExportService(outputDirectory: outputDirectory)
            .exportJPEG(from: source, filename: "result")
        let result = try #require(UIImage(data: Data(contentsOf: url)))

        #expect(url.lastPathComponent == "result.jpg")
        #expect(result.size == CGSize(width: 40, height: 60))
    }

    @Test @MainActor func previewProviderAppliesClientEditRecipe() async throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceURL = rootDirectory.appendingPathComponent("source.png")
        try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let image = makeSolidImage(size: CGSize(width: 80, height: 40), color: .purple)
        try #require(image.pngData()).write(to: sourceURL, options: .atomic)
        let source = TestProcessingSource(
            imageSourceURL: sourceURL,
            imageEditRecipe: ImageEditRecipe(
                rotationDegrees: 90,
                crop: ImageEditCrop(x: 0, y: 0, width: 0.75, height: 1)
            )
        )

        let renderedPreview = await ImagePreviewProvider().preview(
            from: source,
            maxPixelSize: 480
        )
        let preview = try #require(renderedPreview)

        #expect(preview.size == CGSize(width: 40, height: 60))
    }

    @Test @MainActor func previewProviderReturnsNilForMissingSource() async {
        let source = TestProcessingSource(
            imageSourceURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString),
            imageEditRecipe: ImageEditRecipe()
        )

        let preview = await ImagePreviewProvider().preview(
            from: source,
            maxPixelSize: 480
        )

        #expect(preview == nil)
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

    @Test func cameraPositionToggleMovesBetweenFrontAndBack() {
        #expect(CameraPositionToggle.opposite(of: .back) == .front)
        #expect(CameraPositionToggle.opposite(of: .front) == .back)
    }

    @Test func unspecifiedCameraPositionDefaultsToFrontWhenToggled() {
        #expect(CameraPositionToggle.opposite(of: .unspecified) == .front)
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

    @Test func editorCropConvertsTopLeftOriginToCoreImageCoordinates() {
        let crop = ImageEditCrop(x: 0.1, y: 0.2, width: 0.5, height: 0.3)

        #expect(crop.coreImageNormalizedRect == CGRect(x: 0.1, y: 0.5, width: 0.5, height: 0.3))
    }

    @Test func fullEditorCropIsIdentityInCoreImageCoordinates() {
        let crop = ImageEditCrop(x: 0, y: 0, width: 1, height: 1)

        #expect(crop.coreImageNormalizedRect == CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    @Test func editorTopAndBottomCropsMapToOppositeCoreImageEdges() {
        let top = ImageEditCrop(x: 0, y: 0, width: 1, height: 0.25)
        let bottom = ImageEditCrop(x: 0, y: 0.75, width: 1, height: 0.25)

        #expect(top.coreImageNormalizedRect == CGRect(x: 0, y: 0.75, width: 1, height: 0.25))
        #expect(bottom.coreImageNormalizedRect == CGRect(x: 0, y: 0, width: 1, height: 0.25))
    }

    @Test func cropResizeMovesTopEdgeAndPreservesBottomCoordinate() {
        let crop = ImageEditCrop(x: 0.1, y: 0.2, width: 0.5, height: 0.6)

        let resized = ImageEditCropper.resized(
            crop,
            edge: .top,
            horizontalDelta: 0,
            verticalDelta: 0.25
        )

        #expect(abs(resized.y - 0.45) < 0.001)
        #expect(abs(resized.height - 0.35) < 0.001)
        #expect(abs((resized.y + resized.height) - 0.8) < 0.001)
    }

    @Test func cropResizeTrailingEdgeClampsToImageBounds() {
        let crop = ImageEditCrop(x: 0.2, y: 0.1, width: 0.4, height: 0.7)

        let resized = ImageEditCropper.resized(
            crop,
            edge: .trailing,
            horizontalDelta: 0.8,
            verticalDelta: 0
        )

        #expect(resized.x == crop.x)
        #expect(resized.width == 0.8)
    }

    private func makeSolidImage(size: CGSize, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }

}

private struct TestSnapshot: Codable, Equatable, Sendable {
    let id: String
    let value: Int
}

private struct TestProcessingSource: ImageProcessingSource {
    let imageSourceURL: URL
    let imageEditRecipe: ImageEditRecipe
}
