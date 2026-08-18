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
        }
    }

    private var amount: Double {
        switch selectedPreset.kind {
        case .none: 0
        case .filmGrain: draft.effects.filmGrain.amount
        case .lightLeak: draft.effects.lightLeak.amount
        case .chromaticAberration: draft.effects.chromaticAberration.amount
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
            }
        }
    }

    private func updateGrainSize(_ value: Double) { mutateEffects { $0.filmGrain.size = value } }
    private func updateLeakPosition(_ value: Double) { mutateEffects { $0.lightLeak.position = value } }
    private func updateLeakWarmth(_ value: Double) { mutateEffects { $0.lightLeak.warmth = value } }
    private func updateChromaticDirection(_ value: Double) { mutateEffects { $0.chromaticAberration.direction = value } }
    private func updateChromaticFalloff(_ value: Double) { mutateEffects { $0.chromaticAberration.falloff = value } }

    private func mutateEffects(_ mutation: (inout ImageEffects) -> Void) {
        var effects = draft.effects
        mutation(&effects)
        onEffectsChange(effects)
    }
}

private struct EffectControlRow: View {
    let title: String
    let value: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .frame(width: 58, alignment: .leading)
            EffectValueSlider(externalValue: value, range: range, onChange: onChange, onEnd: onEnd)
        }
    }
}

private struct EffectValueSlider: View {
    let externalValue: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    let onEnd: () -> Void
    @State private var value: Double

    init(externalValue: Double, range: ClosedRange<Double>, onChange: @escaping (Double) -> Void, onEnd: @escaping () -> Void) {
        self.externalValue = externalValue
        self.range = range
        self.onChange = onChange
        self.onEnd = onEnd
        _value = State(initialValue: externalValue)
    }

    var body: some View {
        Slider(value: $value, in: range, onEditingChanged: { if !$0 { onEnd() } })
            .tint(AppColours.buttonBacground)
            .onChange(of: value) { onChange($0) }
            .onChange(of: externalValue) { value = $0 }
    }
}
