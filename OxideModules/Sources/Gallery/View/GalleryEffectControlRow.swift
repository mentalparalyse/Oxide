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
    @State private var value: Double

    init(
        externalValue: Double,
        range: ClosedRange<Double>,
        onChange: @escaping (Double) -> Void,
        onEnd: @escaping () -> Void
    ) {
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
