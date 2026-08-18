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
            if isEnabled(preset.kind) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, AppColours.buttonBacground)
                    .padding(4)
            }
        }
    }

    private func isEnabled(_ kind: GalleryEffectKind) -> Bool {
        switch kind {
        case .none:
            !draft.effects.filmGrain.isEnabled
                && draft.effects.lightLeak.amount == 0
                && draft.effects.chromaticAberration.amount == 0
        case .filmGrain:
            draft.effects.filmGrain.isEnabled
        case .lightLeak:
            draft.effects.lightLeak.amount > 0
        case .chromaticAberration:
            draft.effects.chromaticAberration.amount > 0
        }
    }
}
