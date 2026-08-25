import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryEffectsControlsView: View {
    private static let catalog = GalleryEffectCatalog(presets: GalleryEffectPreset.all)

    let draft: EditorDraft
    let onEffectsChange: (ImageEffects) -> Void
    let onChangeEnded: () -> Void
    let onSelectedKindChange: (GalleryEffectKind?) -> Void

    @State private var selectionID: GalleryEffectPreset.ID
    @State private var expandedSectionID: GalleryEffectSection.ID?
    @State private var showsAdvancedControls = false

    init(
        draft: EditorDraft,
        onEffectsChange: @escaping (ImageEffects) -> Void,
        onChangeEnded: @escaping () -> Void,
        onSelectedKindChange: @escaping (GalleryEffectKind?) -> Void
    ) {
        self.draft = draft
        self.onEffectsChange = onEffectsChange
        self.onChangeEnded = onChangeEnded
        self.onSelectedKindChange = onSelectedKindChange
        let selectionID = GalleryEffectPreset.initialSelectionID(for: draft.effects)
        _selectionID = State(initialValue: selectionID)
        _expandedSectionID = State(
            initialValue: Self.catalog.section(containing: selectionID)?.id ?? Self.catalog.sections.first?.id
        )
    }

    private var selectedPreset: GalleryEffectPreset {
        GalleryEffectPreset.all.first { $0.id == selectionID } ?? GalleryEffectPreset.all[0]
    }

    private var visiblePresets: [GalleryEffectPreset] {
        Self.catalog.sections.first { $0.id == expandedSectionID }?.presets ?? []
    }

    var body: some View {
        VStack(spacing: 8) {
            if showsAdvancedControls, !selectedPreset.isNone {
                ScrollView(.vertical, showsIndicators: false) {
                    advancedControls
                }
            } else {
                primaryControls
                    .padding(.horizontal, 16)

                GalleryEffectCarouselView(
                    draft: draft,
                    presets: visiblePresets,
                    selectionID: selectionID,
                    onSelect: select
                )

                GalleryEffectSectionBar(
                    catalog: Self.catalog,
                    selectionID: selectionID,
                    expandedSectionID: expandedSectionID,
                    onSelectNone: selectNone,
                    onSelectSection: toggleSection
                )
            }
        }
        .padding(.vertical, 8)
        .foregroundStyle(AppColours.appForegroundColor)
        .onAppear { notifySelectedKind() }
        .onDisappear { onSelectedKindChange(nil) }
        .onChange(of: selectionID) { _ in notifySelectedKind() }
        .onChange(of: showsAdvancedControls) { _ in notifySelectedKind() }
    }

    private var primaryControls: some View {
        Group {
            if selectedPreset.isNone {
                Text("Choose an effect")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack(spacing: 10) {
                    Text("Intensity")
                        .frame(width: 86, alignment: .leading)

                    ValueSlider(
                        value: amount,
                        range: 0...1,
                        onChange: updateAmount,
                        onChangeEnded: onChangeEnded
                    )
                    Button { showsAdvancedControls = true } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(AppColours.appSurfaceColor, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Advanced effect controls")
                }
            }
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(AppColours.appMutedForegroundColor)
    }

    private func selectNone() {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedSectionID = nil
        }
        select(Self.catalog.none)
    }

    private func toggleSection(_ section: GalleryEffectSection) {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedSectionID = expandedSectionID == section.id ? nil : section.id
        }
    }

    private var advancedControls: some View {
        VStack(spacing: 8) {
            HStack {
                Button { showsAdvancedControls = false } label: {
                    Label(selectedPreset.name, systemImage: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
                Spacer()
                Button("Reset") { select(GalleryEffectPreset.all[0]) }
                    .font(.system(size: 12, weight: .medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColours.appMutedForegroundColor)
            }

            EffectControlRow(
                title: "Intensity",
                value: amount,
                range: 0...1,
                onChange: updateAmount,
                onEnd: onChangeEnded
            )
            if selectedPreset.kind != .tiltShift,
               selectedPreset.kind != .edgeBlur,
               selectedPreset.kind != .vignette,
               let spatialMask = draft.effects.spatialMask(for: selectedPreset.kind) {
                GallerySpatialEffectControls(
                    mask: spatialMask,
                    onChange: updateSpatialMask,
                    onChangeEnded: onChangeEnded
                )
            }
            secondaryControls
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var secondaryControls: some View {
        switch selectedPreset.kind {
        case .none:
            EmptyView()
        case .filmGrain:
            EffectControlRow(title: "Size", value: draft.effects.filmGrain.size, range: 0.5...4, onChange: updateGrainSize, onEnd: onChangeEnded)
        case .lightLeak:
            EffectControlRow(title: "Position", value: draft.effects.lightLeak.position, range: 0...1, onChange: updateLeakPosition, onEnd: onChangeEnded)
            EffectControlRow(title: "Warmth", value: draft.effects.lightLeak.warmth, range: 0...1, onChange: updateLeakWarmth, onEnd: onChangeEnded)
        case .chromaticAberration:
            EffectControlRow(title: "Direction", value: draft.effects.chromaticAberration.direction, range: 0...1, onChange: updateChromaticDirection, onEnd: onChangeEnded)
            EffectControlRow(title: "Falloff", value: draft.effects.chromaticAberration.falloff, range: 0...1, onChange: updateChromaticFalloff, onEnd: onChangeEnded)
        case .halation:
            EffectControlRow(title: "Radius", value: draft.effects.halation.radius, range: 0...1, onChange: updateHalationRadius, onEnd: onChangeEnded)
            EffectControlRow(title: "Threshold", value: draft.effects.halation.threshold, range: 0...1, onChange: updateHalationThreshold, onEnd: onChangeEnded)
        case .dustAndScratches:
            EffectControlRow(title: "Dust", value: draft.effects.dustAndScratches.dustAmount, range: 0...1, onChange: updateDustAmount, onEnd: onChangeEnded)
            EffectControlRow(title: "Scratches", value: draft.effects.dustAndScratches.scratchAmount, range: 0...1, onChange: updateScratchAmount, onEnd: onChangeEnded)
            EffectControlRow(title: "Size", value: draft.effects.dustAndScratches.particleSize, range: 0...1, onChange: updateParticleSize, onEnd: onChangeEnded)
        case .bloom:
            EffectControlRow(title: "Glow size", value: draft.effects.bloom.radius, range: 0...1, onChange: updateBloomRadius, onEnd: onChangeEnded)
            EffectControlRow(title: "Threshold", value: draft.effects.bloom.threshold, range: 0...1, onChange: updateBloomThreshold, onEnd: onChangeEnded)
            EffectControlRow(title: "Warmth", value: draft.effects.bloom.warmth, range: 0...1, onChange: updateBloomWarmth, onEnd: onChangeEnded)
        case .vhs:
            EffectControlRow(title: "Distortion", value: draft.effects.vhs.distortion, range: 0...1, onChange: updateVHSDistortion, onEnd: onChangeEnded)
            EffectControlRow(title: "Scanlines", value: draft.effects.vhs.scanlines, range: 0...1, onChange: updateVHSScanlines, onEnd: onChangeEnded)
            EffectControlRow(title: "Color bleed", value: draft.effects.vhs.colorBleed, range: 0...1, onChange: updateVHSColorBleed, onEnd: onChangeEnded)
        case .lensWarp:
            EffectControlRow(title: "Warp", value: draft.effects.lensWarp.scale, range: -1...1, onChange: updateLensWarpScale, onEnd: onChangeEnded)
        case .motionBlur:
            EffectControlRow(title: "Distance", value: draft.effects.motionBlur.distance, range: 0...1, onChange: updateMotionDistance, onEnd: onChangeEnded)
            EffectControlRow(title: "Angle", value: draft.effects.motionBlur.angle, range: 0...1, onChange: updateMotionAngle, onEnd: onChangeEnded)
        case .zoomBlur:
            EffectControlRow(title: "Strength", value: draft.effects.zoomBlur.strength, range: 0...1, onChange: updateZoomStrength, onEnd: onChangeEnded)
        case .kaleidoscope:
            EffectControlRow(title: "Segments", value: Double(draft.effects.kaleidoscope.segments), range: 2...12, onChange: updateKaleidoscopeSegments, onEnd: onChangeEnded)
            EffectControlRow(title: "Rotation", value: draft.effects.kaleidoscope.rotation, range: 0...1, onChange: updateKaleidoscopeRotation, onEnd: onChangeEnded)
        case .sparkle:
            EffectControlRow(title: "Threshold", value: draft.effects.sparkle.threshold, range: 0...1, onChange: updateSparkleThreshold, onEnd: onChangeEnded)
            EffectControlRow(title: "Ray length", value: draft.effects.sparkle.rayLength, range: 0...1, onChange: updateSparkleRayLength, onEnd: onChangeEnded)
            EffectControlRow(title: "Rotation", value: draft.effects.sparkle.rotation, range: 0...1, onChange: updateSparkleRotation, onEnd: onChangeEnded)
        case .pixelSort:
            EffectControlRow(title: "Threshold", value: draft.effects.pixelSort.threshold, range: 0...1, onChange: updateSortThreshold, onEnd: onChangeEnded)
            EffectControlRow(title: "Trail length", value: draft.effects.pixelSort.trailLength, range: 0...1, onChange: updateSortTrailLength, onEnd: onChangeEnded)
            EffectControlRow(title: "Direction", value: draft.effects.pixelSort.direction, range: 0...1, onChange: updateSortDirection, onEnd: onChangeEnded)
        case .tiltShift:
            EffectControlRow(title: "Blur", value: draft.effects.tiltShift.blur, range: 0...1, onChange: updateTiltBlur, onEnd: onChangeEnded)
            EffectControlRow(title: "Focus width", value: draft.effects.tiltShift.spatialMask.radius, range: 0.05...1, onChange: updateTiltFocusWidth, onEnd: onChangeEnded)
            EffectControlRow(title: "Feather", value: draft.effects.tiltShift.spatialMask.feather, range: 0...1, onChange: updateTiltFeather, onEnd: onChangeEnded)
            if draft.effects.tiltShift.style == .linear {
                EffectControlRow(title: "Rotation", value: draft.effects.tiltShift.rotation, range: 0...1, onChange: updateTiltRotation, onEnd: onChangeEnded)
            }
        case .edgeBlur:
            EffectControlRow(title: "Blur", value: draft.effects.edgeBlur.blur, range: 0...1, onChange: updateEdgeBlur, onEnd: onChangeEnded)
            EffectControlRow(title: "Focus size", value: draft.effects.edgeBlur.spatialMask.radius, range: 0.05...1, onChange: updateEdgeFocusSize, onEnd: onChangeEnded)
            EffectControlRow(title: "Feather", value: draft.effects.edgeBlur.spatialMask.feather, range: 0...1, onChange: updateEdgeFeather, onEnd: onChangeEnded)
        case .vignette:
            EffectControlRow(title: "Size", value: draft.effects.vignette.size, range: 0...1, onChange: updateVignetteSize, onEnd: onChangeEnded)
            EffectControlRow(title: "Feather", value: draft.effects.vignette.feather, range: 0...1, onChange: updateVignetteFeather, onEnd: onChangeEnded)
            EffectControlRow(title: "Roundness", value: draft.effects.vignette.roundness, range: 0...1, onChange: updateVignetteRoundness, onEnd: onChangeEnded)
            EffectControlRow(title: "Irregularity", value: draft.effects.vignette.irregularity, range: 0...1, onChange: updateVignetteIrregularity, onEnd: onChangeEnded)
        }
    }

    private var amount: Double {
        switch selectedPreset.kind {
        case .none: 0
        case .filmGrain: draft.effects.filmGrain.amount
        case .lightLeak: draft.effects.lightLeak.amount
        case .chromaticAberration: draft.effects.chromaticAberration.amount
        case .halation: draft.effects.halation.amount
        case .dustAndScratches: draft.effects.dustAndScratches.amount
        case .bloom: draft.effects.bloom.amount
        case .vhs: draft.effects.vhs.amount
        case .lensWarp: draft.effects.lensWarp.amount
        case .motionBlur: draft.effects.motionBlur.amount
        case .zoomBlur: draft.effects.zoomBlur.amount
        case .kaleidoscope: draft.effects.kaleidoscope.amount
        case .sparkle: draft.effects.sparkle.amount
        case .pixelSort: draft.effects.pixelSort.amount
        case .tiltShift: draft.effects.tiltShift.amount
        case .edgeBlur: draft.effects.edgeBlur.amount
        case .vignette: draft.effects.vignette.amount
        }
    }

    private func select(_ preset: GalleryEffectPreset) {
        selectionID = preset.id
        showsAdvancedControls = false
        onEffectsChange(preset.applying(to: draft.effects))
        onChangeEnded()
    }

    private func updateAmount(_ value: Double) {
        mutateEffects {
            switch selectedPreset.kind {
            case .none: break
            case .filmGrain: $0.filmGrain.amount = value
            case .lightLeak: $0.lightLeak.amount = value
            case .chromaticAberration: $0.chromaticAberration.amount = value
            case .halation: $0.halation.amount = value
            case .dustAndScratches: $0.dustAndScratches.amount = value
            case .bloom: $0.bloom.amount = value
            case .vhs: $0.vhs.amount = value
            case .lensWarp: $0.lensWarp.amount = value
            case .motionBlur: $0.motionBlur.amount = value
            case .zoomBlur: $0.zoomBlur.amount = value
            case .kaleidoscope: $0.kaleidoscope.amount = value
            case .sparkle: $0.sparkle.amount = value
            case .pixelSort: $0.pixelSort.amount = value
            case .tiltShift: $0.tiltShift.amount = value
            case .edgeBlur: $0.edgeBlur.amount = value
            case .vignette: $0.vignette.amount = value
            }
        }
    }

    private func updateGrainSize(_ value: Double) { mutateEffects { $0.filmGrain.size = value } }
    private func updateLeakPosition(_ value: Double) { mutateEffects { $0.lightLeak.position = value } }
    private func updateLeakWarmth(_ value: Double) { mutateEffects { $0.lightLeak.warmth = value } }
    private func updateChromaticDirection(_ value: Double) { mutateEffects { $0.chromaticAberration.direction = value } }
    private func updateChromaticFalloff(_ value: Double) { mutateEffects { $0.chromaticAberration.falloff = value } }
    private func updateHalationRadius(_ value: Double) { mutateEffects { $0.halation.radius = value } }
    private func updateHalationThreshold(_ value: Double) { mutateEffects { $0.halation.threshold = value } }
    private func updateDustAmount(_ value: Double) { mutateEffects { $0.dustAndScratches.dustAmount = value } }
    private func updateScratchAmount(_ value: Double) { mutateEffects { $0.dustAndScratches.scratchAmount = value } }
    private func updateParticleSize(_ value: Double) { mutateEffects { $0.dustAndScratches.particleSize = value } }
    private func updateBloomRadius(_ value: Double) { mutateEffects { $0.bloom.radius = value } }
    private func updateBloomThreshold(_ value: Double) { mutateEffects { $0.bloom.threshold = value } }
    private func updateBloomWarmth(_ value: Double) { mutateEffects { $0.bloom.warmth = value } }
    private func updateVHSDistortion(_ value: Double) { mutateEffects { $0.vhs.distortion = value } }
    private func updateVHSScanlines(_ value: Double) { mutateEffects { $0.vhs.scanlines = value } }
    private func updateVHSColorBleed(_ value: Double) { mutateEffects { $0.vhs.colorBleed = value } }
    private func updateLensWarpScale(_ value: Double) { mutateEffects { $0.lensWarp.scale = value } }
    private func updateMotionDistance(_ value: Double) { mutateEffects { $0.motionBlur.distance = value } }
    private func updateMotionAngle(_ value: Double) { mutateEffects { $0.motionBlur.angle = value } }
    private func updateZoomStrength(_ value: Double) { mutateEffects { $0.zoomBlur.strength = value } }
    private func updateKaleidoscopeSegments(_ value: Double) { mutateEffects { $0.kaleidoscope.segments = Int(value.rounded()) } }
    private func updateKaleidoscopeRotation(_ value: Double) { mutateEffects { $0.kaleidoscope.rotation = value } }
    private func updateSparkleThreshold(_ value: Double) { mutateEffects { $0.sparkle.threshold = value } }
    private func updateSparkleRayLength(_ value: Double) { mutateEffects { $0.sparkle.rayLength = value } }
    private func updateSparkleRotation(_ value: Double) { mutateEffects { $0.sparkle.rotation = value } }
    private func updateSortThreshold(_ value: Double) { mutateEffects { $0.pixelSort.threshold = value } }
    private func updateSortTrailLength(_ value: Double) { mutateEffects { $0.pixelSort.trailLength = value } }
    private func updateSortDirection(_ value: Double) { mutateEffects { $0.pixelSort.direction = value } }
    private func updateTiltBlur(_ value: Double) { mutateEffects { $0.tiltShift.blur = value } }
    private func updateTiltFocusWidth(_ value: Double) { mutateEffects { $0.tiltShift.spatialMask.radius = value } }
    private func updateTiltFeather(_ value: Double) { mutateEffects { $0.tiltShift.spatialMask.feather = value } }
    private func updateTiltRotation(_ value: Double) { mutateEffects { $0.tiltShift.rotation = value } }
    private func updateEdgeBlur(_ value: Double) { mutateEffects { $0.edgeBlur.blur = value } }
    private func updateEdgeFocusSize(_ value: Double) { mutateEffects { $0.edgeBlur.spatialMask.radius = value } }
    private func updateEdgeFeather(_ value: Double) { mutateEffects { $0.edgeBlur.spatialMask.feather = value } }
    private func updateVignetteSize(_ value: Double) { mutateEffects { $0.vignette.size = value } }
    private func updateVignetteFeather(_ value: Double) { mutateEffects { $0.vignette.feather = value } }
    private func updateVignetteRoundness(_ value: Double) { mutateEffects { $0.vignette.roundness = value } }
    private func updateVignetteIrregularity(_ value: Double) { mutateEffects { $0.vignette.irregularity = value } }

    private func updateSpatialMask(_ mask: ImageSpatialEffectMask) {
        mutateEffects { $0.setSpatialMask(mask, for: selectedPreset.kind) }
        onSelectedKindChange(
            showsAdvancedControls && mask.mode == .spot ? selectedPreset.kind : nil
        )
    }

    private func notifySelectedKind() {
        guard showsAdvancedControls,
              selectedPreset.kind.supportsSpatialMask,
              draft.effects.spatialMask(for: selectedPreset.kind)?.mode == .spot
        else {
            onSelectedKindChange(nil)
            return
        }
        onSelectedKindChange(selectedPreset.kind)
    }

    private func mutateEffects(_ mutation: (inout ImageEffects) -> Void) {
        var effects = draft.effects
        mutation(&effects)
        onEffectsChange(effects)
    }
}
