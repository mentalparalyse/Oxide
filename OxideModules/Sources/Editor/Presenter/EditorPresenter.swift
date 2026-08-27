import AppCore
import CoreGraphics
import Combine
import ImageProcessor

@MainActor
public final class EditorPresenter: ObservableObject {
    @Published public private(set) var draft: EditorDraft
    @Published public private(set) var canUndo = false
    @Published public private(set) var sourceSize: CGSize?

    public let filters: [GalleryFilter]
    public let filterCatalog: GalleryFilterCatalog

    private let interactor: EditorInteractorProtocol
    private let analytics: any AppAnalyticsTracking
    private let historySetupTask: Task<Void, Never>
    private let onCancel: @MainActor () -> Void
    private let onSave: @MainActor (EditorAsset) -> Void
    private let onError: @MainActor (String) -> Void

    init(
        asset: EditorAsset,
        interactor: EditorInteractorProtocol,
        analytics: any AppAnalyticsTracking = NoOpAppAnalyticsTracker(),
        onCancel: @escaping @MainActor () -> Void,
        onSave: @escaping @MainActor (EditorAsset) -> Void,
        onError: @escaping @MainActor (String) -> Void
    ) {
        let filters = GalleryFilter.all
        self.draft = EditorDraft(asset: asset)
        self.filters = filters
        self.filterCatalog = GalleryFilterCatalog(filters: filters)
        self.interactor = interactor
        self.analytics = analytics
        historySetupTask = Task { await interactor.beginHistory(for: asset) }
        self.onCancel = onCancel
        self.onSave = onSave
        self.onError = onError
        sourceSize = interactor.sourceImageSize(for: asset.imageURI)
        interactor.preloadFilterPreviews(filters: filters)
    }

    public func cancel() {
        analytics.track(.editCancelled)
        onCancel()
    }
    public func save() {
        analytics.track(.editSaved)
        onSave(draft.committed())
    }

    public func selectFilter(_ filterID: String) async {
        guard filters.contains(where: { $0.id == filterID }) else {
            onError("Filter unavailable")
            return
        }
        guard draft.selectedFilterID != filterID else { return }
        draft.selectedFilterID = filterID
        draft.filterIntensity = 0.5
        analytics.track(.filterApplied(filterID: filterID))
        await recordCurrentStep()
    }

    public func setFilterIntensity(_ intensity: Double) {
        draft.filterIntensity = min(max(intensity, 0), 1)
    }

    public func commitFilterIntensity() async { await recordCurrentStep() }

    public func rotate(by degrees: Int) async {
        draft.rotationDegrees = ImageEditRotation.normalized(draft.rotationDegrees + degrees)
        await recordCurrentStep()
    }

    public func setCropAspectRatio(_ aspectRatio: Double?) async {
        if let aspectRatio {
            guard let sourceSize else {
                onError("Crop unavailable")
                return
            }
            draft.crop = ImageEditCropper.centeredCrop(sourceSize: sourceSize, aspectRatio: aspectRatio)
            draft.cropAspectRatio = aspectRatio
        } else {
            draft.crop = nil
            draft.cropAspectRatio = nil
        }
        await recordCurrentStep()
    }

    public func resizeCrop(
        edge: ImageEditCropEdge,
        baseCrop: ImageEditCrop?,
        horizontalDelta: Double,
        verticalDelta: Double
    ) {
        draft.crop = ImageEditCropper.resized(
            baseCrop,
            edge: edge,
            horizontalDelta: horizontalDelta,
            verticalDelta: verticalDelta
        )
        draft.cropAspectRatio = nil
    }

    public func commitCropResize() async { await recordCurrentStep() }

    public func setAdjustment(_ kind: ImageAdjustmentKind, value: Double) {
        var adjustments = draft.adjustments
        switch kind {
        case .exposure: adjustments.exposure = min(max(value, -2), 2)
        case .contrast: adjustments.contrast = min(max(value, 0.5), 1.5)
        case .saturation: adjustments.saturation = min(max(value, 0), 2)
        case .brightness: adjustments.brightness = min(max(value, -0.5), 0.5)
        case .monochrome: return
        }
        draft.adjustments = adjustments
    }

    public func toggleMonochrome() async {
        draft.adjustments.isMonochrome.toggle()
        await recordCurrentStep()
    }

    public func commitAdjustment() async { await recordCurrentStep() }
    public func setEffects(_ effects: ImageEffects) { draft.effects = effects }
    public func commitEffects() async { await recordCurrentStep() }

    public func undo() async {
        await historySetupTask.value
        let state = await interactor.undo()
        if let currentDraft = state.currentDraft {
            draft = currentDraft
        }
        canUndo = state.canUndo
    }

    private func recordCurrentStep() async {
        await historySetupTask.value
        let state = await interactor.record(draft)
        canUndo = state.canUndo
    }
}
