import ImageProcessor
@preconcurrency import SwiftUI
import UIComponents

private enum GalleryEffect: String, CaseIterable, Identifiable {
    case filmGrain = "Film Grain"
    case lightLeak = "Light Leak"
    case chromaticAberration = "Chromatic"

    var id: Self { self }
}

struct GalleryEffectsControlsView: View {
    let effects: ImageEffects
    let onAmountChange: (Double) -> Void
    let onSizeChange: (Double) -> Void
    let onFilmGrainChangeEnded: () -> Void
    let onLeakAmountChange: (Double) -> Void
    let onLeakPositionChange: (Double) -> Void
    let onLeakWarmthChange: (Double) -> Void
    let onLightLeakChangeEnded: () -> Void
    let onChromaticAmountChange: (Double) -> Void
    let onChromaticDirectionChange: (Double) -> Void
    let onChromaticFalloffChange: (Double) -> Void
    let onChromaticChangeEnded: () -> Void

    @State private var selection: GalleryEffect = .filmGrain

    var body: some View {
        VStack(spacing: 10) {
            effectPicker
            selectedControls
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .foregroundStyle(AppColours.appForegroundColor)
    }

    @ViewBuilder
    private var selectedControls: some View {
        switch selection {
        case .filmGrain: filmGrainControls
        case .lightLeak: lightLeakControls
        case .chromaticAberration: chromaticControls
        }
    }

    private var effectPicker: some View {
        HStack(spacing: 8) {
            ForEach(GalleryEffect.allCases) { effect in
                Button(effect.rawValue) { selection = effect }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(selection == effect ? Color.white : AppColours.appMutedForegroundColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(selection == effect ? AppColours.buttonBacground : AppColours.appSurfaceColor, in: Capsule())
                    .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private var filmGrainControls: some View {
        VStack(spacing: 8) {
            effectSlider("Amount", value: effects.filmGrain.amount, range: 0...1, onChange: onAmountChange, onEnd: onFilmGrainChangeEnded)
            effectSlider("Size", value: effects.filmGrain.size, range: 0.5...4, onChange: onSizeChange, onEnd: onFilmGrainChangeEnded)
        }
    }

    private var lightLeakControls: some View {
        VStack(spacing: 6) {
            effectSlider("Amount", value: effects.lightLeak.amount, range: 0...1, onChange: onLeakAmountChange, onEnd: onLightLeakChangeEnded)
            effectSlider("Position", value: effects.lightLeak.position, range: 0...1, onChange: onLeakPositionChange, onEnd: onLightLeakChangeEnded)
            effectSlider("Warmth", value: effects.lightLeak.warmth, range: 0...1, onChange: onLeakWarmthChange, onEnd: onLightLeakChangeEnded)
        }
    }

    private var chromaticControls: some View {
        VStack(spacing: 6) {
            effectSlider("Amount", value: effects.chromaticAberration.amount, range: 0...1, onChange: onChromaticAmountChange, onEnd: onChromaticChangeEnded)
            effectSlider("Direction", value: effects.chromaticAberration.direction, range: 0...1, onChange: onChromaticDirectionChange, onEnd: onChromaticChangeEnded)
            effectSlider("Falloff", value: effects.chromaticAberration.falloff, range: 0...1, onChange: onChromaticFalloffChange, onEnd: onChromaticChangeEnded)
        }
    }

    private func effectSlider(
        _ title: String,
        value: Double,
        range: ClosedRange<Double>,
        onChange: @escaping (Double) -> Void,
        onEnd: @escaping () -> Void
    ) -> some View {
        EffectSliderRow(
            title: title,
            externalValue: value,
            range: range,
            onChange: onChange,
            onEnd: onEnd
        )
    }
}

private struct EffectSliderRow: View {
    let title: String
    let externalValue: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    let onEnd: () -> Void

    @State private var value: Double

    init(
        title: String,
        externalValue: Double,
        range: ClosedRange<Double>,
        onChange: @escaping (Double) -> Void,
        onEnd: @escaping () -> Void
    ) {
        self.title = title
        self.externalValue = externalValue
        self.range = range
        self.onChange = onChange
        self.onEnd = onEnd
        _value = State(initialValue: externalValue)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .frame(width: 52, alignment: .leading)
            Slider(value: $value, in: range, onEditingChanged: { if !$0 { onEnd() } })
                .tint(AppColours.buttonBacground)
        }
        .onChange(of: value) { onChange($0) }
        .onChange(of: externalValue) { value = $0 }
    }
}
