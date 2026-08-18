import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryEffectsControlsView: View {
    let effects: ImageEffects
    let onAmountChange: (Double) -> Void
    let onSizeChange: (Double) -> Void
    let onChangeEnded: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("Film Grain", systemImage: "circle.dotted")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(Int(effects.filmGrain.amount * 100))%")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColours.appMutedForegroundColor)
            }

            effectSlider(
                title: "Amount",
                value: effects.filmGrain.amount,
                range: 0...1,
                onChange: onAmountChange
            )

            effectSlider(
                title: "Size",
                value: effects.filmGrain.size,
                range: 0.5...4,
                onChange: onSizeChange
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundStyle(AppColours.appForegroundColor)
    }

    private func effectSlider(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .frame(width: 52, alignment: .leading)

            Slider(
                value: Binding(get: { value }, set: onChange),
                in: range,
                onEditingChanged: { isEditing in
                    if !isEditing { onChangeEnded() }
                }
            )
            .tint(AppColours.buttonBacground)
        }
    }
}
