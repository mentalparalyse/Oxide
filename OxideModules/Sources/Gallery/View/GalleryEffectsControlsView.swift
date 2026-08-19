import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryEffectsControlsView: View {
    let draft: GalleryDraft
    let onEffectsChange: (ImageEffects) -> Void
    let onChangeEnded: () -> Void

    @State private var selectionID: GalleryEffectPreset.ID
    @State private var showsAdvancedControls = false

    init(
        draft: GalleryDraft,
        onEffectsChange: @escaping (ImageEffects) -> Void,
        onChangeEnded: @escaping () -> Void
    ) {
        self.draft = draft
        self.onEffectsChange = onEffectsChange
        self.onChangeEnded = onChangeEnded
        _selectionID = State(initialValue: GalleryEffectPreset.initialSelectionID(for: draft.effects))
    }

    private var selectedPreset: GalleryEffectPreset {
        GalleryEffectPreset.all.first { $0.id == selectionID } ?? GalleryEffectPreset.all[0]
    }

    var body: some View {
        VStack(spacing: 8) {
            if showsAdvancedControls, !selectedPreset.isNone {
                advancedControls
            } else {
                GalleryEffectCarouselView(
                    draft: draft,
                    presets: GalleryEffectPreset.all,
                    selectionID: selectionID,
                    onSelect: select
                )
                primaryControls
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
        .foregroundStyle(AppColours.appForegroundColor)
    }

    private var primaryControls: some View {
        HStack(spacing: 10) {
            Text(selectedPreset.isNone ? "Choose an effect" : "Intensity")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .frame(width: 86, alignment: .leading)

            if !selectedPreset.isNone {
                EffectValueSlider(
                    externalValue: amount,
                    range: 0...1,
                    onChange: updateAmount,
                    onEnd: onChangeEnded
                )
                Button { showsAdvancedControls = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(AppColours.appSurfaceColor, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Advanced effect controls")
            } else {
                Spacer()
            }
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

    private func mutateEffects(_ mutation: (inout ImageEffects) -> Void) {
        var effects = draft.effects
        mutation(&effects)
        onEffectsChange(effects)
    }
}
