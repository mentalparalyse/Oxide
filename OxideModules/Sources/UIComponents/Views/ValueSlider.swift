import SwiftUI

public struct ValueSlider: View {
    private let value: Double
    private let range: ClosedRange<Double>
    private let onChange: (Double) -> Void
    private let onChangeEnded: () -> Void

    public init(
        value: Double,
        range: ClosedRange<Double>,
        onChange: @escaping (Double) -> Void,
        onChangeEnded: @escaping () -> Void
    ) {
        self.value = value
        self.range = range
        self.onChange = onChange
        self.onChangeEnded = onChangeEnded
    }

    public var body: some View {
        Slider(
            value: Binding(get: { value }, set: { onChange($0) }),
            in: range,
            onEditingChanged: { if !$0 { onChangeEnded() } }
        )
        .tint(AppColours.buttonBacground)
    }
}

public struct LabeledValueSlider: View {
    private let title: String
    private let value: Double
    private let range: ClosedRange<Double>
    private let valueText: String
    private let onChange: (Double) -> Void
    private let onChangeEnded: () -> Void

    public init(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        valueText: String,
        onChange: @escaping (Double) -> Void,
        onChangeEnded: @escaping () -> Void
    ) {
        self.title = title
        self.value = value
        self.range = range
        self.valueText = valueText
        self.onChange = onChange
        self.onChangeEnded = onChangeEnded
    }

    public var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColours.appMutedForegroundColor)
            ValueSlider(value: value, range: range, onChange: onChange, onChangeEnded: onChangeEnded)
            Text(valueText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .frame(width: 32, alignment: .trailing)
        }
    }
}
