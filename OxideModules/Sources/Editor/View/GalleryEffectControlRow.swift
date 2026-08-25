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
            ValueSlider(
                value: value,
                range: range,
                onChange: onChange,
                onChangeEnded: onEnd
            )
        }
    }
}
