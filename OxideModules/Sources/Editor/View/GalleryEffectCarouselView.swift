import SwiftUI
import UIComponents

struct GalleryEffectCarouselView: View {
    let draft: EditorDraft
    let presets: [GalleryEffectPreset]
    let selectionID: GalleryEffectPreset.ID
    let onSelect: (GalleryEffectPreset) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(presets) { preset in
                    Button { onSelect(preset) } label: {
                        VStack(spacing: 5) {
                            preview(for: preset)
                            Text(preset.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(
                                    selectionID == preset.id
                                        ? AppColours.appForegroundColor
                                        : AppColours.appMutedForegroundColor
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(preset.name)
                    .accessibilityAddTraits(selectionID == preset.id ? .isSelected : [])
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func preview(for preset: GalleryEffectPreset) -> some View {
        LUTPreviewImage(
            imageURL: draft.asset.imageURI,
            presetID: draft.selectedFilterID,
            intensity: draft.filterIntensity,
            rotationDegrees: draft.rotationDegrees,
            crop: draft.crop,
            adjustments: draft.adjustments,
            effects: preset.applying(to: draft.effects),
            contentMode: .fill,
            maxPixelSize: 120
        )
        .frame(width: 66, height: 66)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    selectionID == preset.id
                        ? AppColours.buttonBacground
                        : AppColours.appBorderColor,
                    lineWidth: selectionID == preset.id ? 2 : 1
                )
        }
        .overlay(alignment: .topTrailing) {
            if isEnabled(preset) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, AppColours.buttonBacground)
                    .padding(4)
            }
        }
    }

    private func isEnabled(_ preset: GalleryEffectPreset) -> Bool {
        switch preset.kind {
        case .none:
            return !draft.effects.filmGrain.isEnabled
                && draft.effects.lightLeak.amount == 0
                && draft.effects.chromaticAberration.amount == 0
                && !draft.effects.halation.isEnabled
                && !draft.effects.dustAndScratches.isEnabled
                && !draft.effects.bloom.isEnabled
                && !draft.effects.vhs.isEnabled
                && !draft.effects.lensWarp.isEnabled
                && !draft.effects.motionBlur.isEnabled
                && !draft.effects.zoomBlur.isEnabled
                && !draft.effects.kaleidoscope.isEnabled
                && !draft.effects.sparkle.isEnabled
                && !draft.effects.pixelSort.isEnabled
                && !draft.effects.tiltShift.isEnabled
                && !draft.effects.edgeBlur.isEnabled
                && !draft.effects.vignette.isEnabled
                && !draft.effects.lensDirt.isEnabled
        case .filmGrain:
            guard draft.effects.filmGrain.isEnabled else { return false }
        case .lightLeak:
            guard draft.effects.lightLeak.amount > 0 else { return false }
        case .chromaticAberration:
            guard draft.effects.chromaticAberration.amount > 0 else { return false }
        case .halation:
            guard draft.effects.halation.isEnabled else { return false }
        case .dustAndScratches:
            guard draft.effects.dustAndScratches.isEnabled else { return false }
        case .bloom:
            guard draft.effects.bloom.isEnabled else { return false }
        case .vhs:
            guard draft.effects.vhs.isEnabled else { return false }
        case .lensWarp:
            guard draft.effects.lensWarp.isEnabled else { return false }
        case .motionBlur:
            guard draft.effects.motionBlur.isEnabled else { return false }
        case .zoomBlur:
            guard draft.effects.zoomBlur.isEnabled else { return false }
        case .kaleidoscope:
            guard draft.effects.kaleidoscope.isEnabled else { return false }
        case .sparkle:
            guard draft.effects.sparkle.isEnabled else { return false }
        case .pixelSort:
            guard draft.effects.pixelSort.isEnabled else { return false }
        case .tiltShift:
            guard draft.effects.tiltShift.isEnabled else { return false }
        case .edgeBlur:
            guard draft.effects.edgeBlur.isEnabled else { return false }
        case .vignette:
            guard draft.effects.vignette.isEnabled else { return false }
        case .lensDirt:
            guard draft.effects.lensDirt.isEnabled else { return false }
        }

        return closestEnabledPreset(for: preset.kind)?.id == preset.id
    }

    private func closestEnabledPreset(for kind: GalleryEffectKind) -> GalleryEffectPreset? {
        presets
            .filter { $0.kind == kind }
            .min { presetDistance($0) < presetDistance($1) }
    }

    private func presetDistance(_ preset: GalleryEffectPreset) -> Double {
        let targetEffects = preset.applying(to: .neutral)

        switch preset.kind {
        case .none:
            return 0
        case .filmGrain:
            return abs(draft.effects.filmGrain.amount - targetEffects.filmGrain.amount)
                + abs(draft.effects.filmGrain.size - targetEffects.filmGrain.size)
        case .lightLeak:
            return abs(draft.effects.lightLeak.amount - targetEffects.lightLeak.amount)
                + abs(draft.effects.lightLeak.position - targetEffects.lightLeak.position)
                + abs(draft.effects.lightLeak.warmth - targetEffects.lightLeak.warmth)
        case .chromaticAberration:
            return abs(draft.effects.chromaticAberration.amount - targetEffects.chromaticAberration.amount)
                + abs(draft.effects.chromaticAberration.direction - targetEffects.chromaticAberration.direction)
                + abs(draft.effects.chromaticAberration.falloff - targetEffects.chromaticAberration.falloff)
        case .halation:
            return abs(draft.effects.halation.amount - targetEffects.halation.amount)
                + abs(draft.effects.halation.radius - targetEffects.halation.radius)
                + abs(draft.effects.halation.threshold - targetEffects.halation.threshold)
        case .dustAndScratches:
            return abs(draft.effects.dustAndScratches.amount - targetEffects.dustAndScratches.amount)
                + abs(draft.effects.dustAndScratches.dustAmount - targetEffects.dustAndScratches.dustAmount)
                + abs(draft.effects.dustAndScratches.scratchAmount - targetEffects.dustAndScratches.scratchAmount)
                + abs(draft.effects.dustAndScratches.particleSize - targetEffects.dustAndScratches.particleSize)
        case .bloom:
            return abs(draft.effects.bloom.amount - targetEffects.bloom.amount)
                + abs(draft.effects.bloom.radius - targetEffects.bloom.radius)
                + abs(draft.effects.bloom.threshold - targetEffects.bloom.threshold)
                + abs(draft.effects.bloom.warmth - targetEffects.bloom.warmth)
        case .vhs:
            return abs(draft.effects.vhs.amount - targetEffects.vhs.amount)
                + abs(draft.effects.vhs.distortion - targetEffects.vhs.distortion)
                + abs(draft.effects.vhs.scanlines - targetEffects.vhs.scanlines)
                + abs(draft.effects.vhs.colorBleed - targetEffects.vhs.colorBleed)
        case .lensWarp:
            return abs(draft.effects.lensWarp.amount - targetEffects.lensWarp.amount)
                + abs(draft.effects.lensWarp.scale - targetEffects.lensWarp.scale)
        case .motionBlur:
            return abs(draft.effects.motionBlur.amount - targetEffects.motionBlur.amount)
                + abs(draft.effects.motionBlur.distance - targetEffects.motionBlur.distance)
                + abs(draft.effects.motionBlur.angle - targetEffects.motionBlur.angle)
        case .zoomBlur:
            return abs(draft.effects.zoomBlur.amount - targetEffects.zoomBlur.amount)
                + abs(draft.effects.zoomBlur.strength - targetEffects.zoomBlur.strength)
        case .kaleidoscope:
            return abs(draft.effects.kaleidoscope.amount - targetEffects.kaleidoscope.amount)
                + abs(Double(draft.effects.kaleidoscope.segments - targetEffects.kaleidoscope.segments))
                + abs(draft.effects.kaleidoscope.rotation - targetEffects.kaleidoscope.rotation)
        case .sparkle:
            return abs(draft.effects.sparkle.amount - targetEffects.sparkle.amount)
                + abs(draft.effects.sparkle.threshold - targetEffects.sparkle.threshold)
                + abs(draft.effects.sparkle.rayLength - targetEffects.sparkle.rayLength)
                + abs(draft.effects.sparkle.rotation - targetEffects.sparkle.rotation)
        case .pixelSort:
            return abs(draft.effects.pixelSort.amount - targetEffects.pixelSort.amount)
                + abs(draft.effects.pixelSort.threshold - targetEffects.pixelSort.threshold)
                + abs(draft.effects.pixelSort.trailLength - targetEffects.pixelSort.trailLength)
                + abs(draft.effects.pixelSort.direction - targetEffects.pixelSort.direction)
        case .tiltShift:
            return abs(draft.effects.tiltShift.amount - targetEffects.tiltShift.amount)
                + abs(draft.effects.tiltShift.blur - targetEffects.tiltShift.blur)
                + abs(draft.effects.tiltShift.rotation - targetEffects.tiltShift.rotation)
                + abs(draft.effects.tiltShift.spatialMask.radius - targetEffects.tiltShift.spatialMask.radius)
        case .edgeBlur:
            return abs(draft.effects.edgeBlur.amount - targetEffects.edgeBlur.amount)
                + abs(draft.effects.edgeBlur.blur - targetEffects.edgeBlur.blur)
                + abs(draft.effects.edgeBlur.spatialMask.radius - targetEffects.edgeBlur.spatialMask.radius)
                + abs(draft.effects.edgeBlur.spatialMask.feather - targetEffects.edgeBlur.spatialMask.feather)
        case .vignette:
            return abs(draft.effects.vignette.amount - targetEffects.vignette.amount)
                + abs(draft.effects.vignette.size - targetEffects.vignette.size)
                + abs(draft.effects.vignette.feather - targetEffects.vignette.feather)
                + abs(draft.effects.vignette.roundness - targetEffects.vignette.roundness)
                + abs(draft.effects.vignette.irregularity - targetEffects.vignette.irregularity)
        case .lensDirt:
            return abs(draft.effects.lensDirt.amount - targetEffects.lensDirt.amount)
                + abs(draft.effects.lensDirt.density - targetEffects.lensDirt.density)
                + abs(draft.effects.lensDirt.smudge - targetEffects.lensDirt.smudge)
                + abs(draft.effects.lensDirt.flare - targetEffects.lensDirt.flare)
        }
    }
}
