import SwiftUI
import UIComponents

struct EffectControlRow: View {
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
            EffectValueSlider(
                externalValue: value,
                range: range,
                onChange: onChange,
                onEnd: onEnd
            )
        }
    }
}

struct EffectValueSlider: View {
    let externalValue: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    let onEnd: () -> Void

    var body: some View {
        Slider(
            value: Binding(
                get: { externalValue },
                set: { newValue in onChange(newValue) }
            ),
            in: range,
            onEditingChanged: { isEditing in
                if !isEditing { onEnd() }
            }
        )
        .tint(AppColours.buttonBacground)
    }
}
