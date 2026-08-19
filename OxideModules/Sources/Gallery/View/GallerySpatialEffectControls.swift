import ImageProcessor
import SwiftUI
import UIComponents

struct GallerySpatialEffectControls: View {
    let mask: ImageSpatialEffectMask
    let onChange: (ImageSpatialEffectMask) -> Void
    let onChangeEnded: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text("Area")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColours.appMutedForegroundColor)
                Spacer()
                areaButton("Frame", mode: .fullFrame)
                areaButton("Spot", mode: .spot)
            }

            if mask.mode == .spot {
                EffectControlRow(
                    title: "Spot size",
                    value: mask.radius,
                    range: 0.05...1,
                    onChange: updateRadius,
                    onEnd: onChangeEnded
                )
                EffectControlRow(
                    title: "Feather",
                    value: mask.feather,
                    range: 0...1,
                    onChange: updateFeather,
                    onEnd: onChangeEnded
                )
            }
        }
    }

    private func areaButton(
        _ title: String,
        mode: ImageSpatialEffectMask.Mode
    ) -> some View {
        Button(title) {
            guard mask.mode != mode else { return }
            onChange(copy(mode: mode))
            onChangeEnded()
        }
        .font(.system(size: 12, weight: .semibold))
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .foregroundStyle(mask.mode == mode ? AppColours.appColor : AppColours.appForegroundColor)
        .background(
            mask.mode == mode ? AppColours.appForegroundColor : AppColours.appSurfaceColor,
            in: Capsule()
        )
    }

    private func updateRadius(_ value: Double) {
        onChange(copy(radius: value))
    }

    private func updateFeather(_ value: Double) {
        onChange(copy(feather: value))
    }

    private func copy(
        mode: ImageSpatialEffectMask.Mode? = nil,
        radius: Double? = nil,
        feather: Double? = nil
    ) -> ImageSpatialEffectMask {
        ImageSpatialEffectMask(
            mode: mode ?? mask.mode,
            centerX: mask.centerX,
            centerY: mask.centerY,
            radius: radius ?? mask.radius,
            feather: feather ?? mask.feather
        )
    }
}
