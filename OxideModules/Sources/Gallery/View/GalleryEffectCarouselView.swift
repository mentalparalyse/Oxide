import SwiftUI
import UIComponents

struct GalleryEffectCarouselView: View {
    let draft: GalleryDraft
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
            imageURL: draft.photo.imageURI,
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
        }

        return closestEnabledPreset(for: preset.kind)?.id == preset.id
    }

    private func closestEnabledPreset(for kind: GalleryEffectKind) -> GalleryEffectPreset? {
        presets
            .filter { $0.kind == kind }
            .min { presetDistance($0) < presetDistance($1) }
    }

    private func presetDistance(_ preset: GalleryEffectPreset) -> Double {
        switch preset.kind {
        case .none:
            return 0
        case .filmGrain:
            return abs(draft.effects.filmGrain.amount - preset.previewEffects.filmGrain.amount)
                + abs(draft.effects.filmGrain.size - preset.previewEffects.filmGrain.size)
        case .lightLeak:
            return abs(draft.effects.lightLeak.amount - preset.previewEffects.lightLeak.amount)
                + abs(draft.effects.lightLeak.position - preset.previewEffects.lightLeak.position)
                + abs(draft.effects.lightLeak.warmth - preset.previewEffects.lightLeak.warmth)
        case .chromaticAberration:
            return abs(draft.effects.chromaticAberration.amount - preset.previewEffects.chromaticAberration.amount)
                + abs(draft.effects.chromaticAberration.direction - preset.previewEffects.chromaticAberration.direction)
                + abs(draft.effects.chromaticAberration.falloff - preset.previewEffects.chromaticAberration.falloff)
        case .halation:
            return abs(draft.effects.halation.amount - preset.previewEffects.halation.amount)
                + abs(draft.effects.halation.radius - preset.previewEffects.halation.radius)
                + abs(draft.effects.halation.threshold - preset.previewEffects.halation.threshold)
        case .dustAndScratches:
            return abs(draft.effects.dustAndScratches.amount - preset.previewEffects.dustAndScratches.amount)
                + abs(draft.effects.dustAndScratches.dustAmount - preset.previewEffects.dustAndScratches.dustAmount)
                + abs(draft.effects.dustAndScratches.scratchAmount - preset.previewEffects.dustAndScratches.scratchAmount)
                + abs(draft.effects.dustAndScratches.particleSize - preset.previewEffects.dustAndScratches.particleSize)
        case .bloom:
            return abs(draft.effects.bloom.amount - preset.previewEffects.bloom.amount)
                + abs(draft.effects.bloom.radius - preset.previewEffects.bloom.radius)
                + abs(draft.effects.bloom.threshold - preset.previewEffects.bloom.threshold)
                + abs(draft.effects.bloom.warmth - preset.previewEffects.bloom.warmth)
        case .vhs:
            return abs(draft.effects.vhs.amount - preset.previewEffects.vhs.amount)
                + abs(draft.effects.vhs.distortion - preset.previewEffects.vhs.distortion)
                + abs(draft.effects.vhs.scanlines - preset.previewEffects.vhs.scanlines)
                + abs(draft.effects.vhs.colorBleed - preset.previewEffects.vhs.colorBleed)
        case .lensWarp:
            return abs(draft.effects.lensWarp.amount - preset.previewEffects.lensWarp.amount)
                + abs(draft.effects.lensWarp.scale - preset.previewEffects.lensWarp.scale)
        }
    }
}
