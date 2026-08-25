// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryAdjustmentControlsView: View {
    let adjustments: ImageAdjustments
    let onChange: (ImageAdjustmentKind, Double) -> Void
    let onChangeEnded: () -> Void
    let onToggleMonochrome: () -> Void

    @State private var selectedKind: ImageAdjustmentKind = .exposure

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ImageAdjustmentKind.allCases) { kind in
                        adjustmentButton(kind)
                    }
                }
                .padding(.horizontal, 16)
            }

            if selectedKind == .monochrome {
                Toggle(
                    "Black & White",
                    isOn: Binding(
                        get: { adjustments.isMonochrome },
                        set: { _ in onToggleMonochrome() }
                    )
                )
                .tint(AppColours.buttonBacground)
                .padding(.horizontal, 16)
            } else {
                adjustmentSlider
                    .padding(.horizontal, 16)
            }
        }
    }

    private func adjustmentButton(_ kind: ImageAdjustmentKind) -> some View {
        Button {
            selectedKind = kind
        } label: {
            Text(title(for: kind))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(
                    selectedKind == kind
                        ? AppColours.appForegroundColor
                        : AppColours.appMutedForegroundColor
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    selectedKind == kind
                        ? AppColours.appBorderColor
                        : AppColours.appSurfaceColor,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private var adjustmentSlider: some View {
        VStack(spacing: 6) {
            ValueSlider(
                value: value(for: selectedKind),
                range: range(for: selectedKind),
                onChange: { onChange(selectedKind, $0) },
                onChangeEnded: onChangeEnded
            )

            Text(formattedValue(for: selectedKind))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColours.appMutedForegroundColor)
        }
    }

    private func value(for kind: ImageAdjustmentKind) -> Double {
        switch kind {
        case .exposure: adjustments.exposure
        case .contrast: adjustments.contrast
        case .saturation: adjustments.saturation
        case .brightness: adjustments.brightness
        case .monochrome: adjustments.isMonochrome ? 1 : 0
        }
    }

    private func range(for kind: ImageAdjustmentKind) -> ClosedRange<Double> {
        switch kind {
        case .exposure: -2...2
        case .contrast: 0.5...1.5
        case .saturation: 0...2
        case .brightness: -0.5...0.5
        case .monochrome: 0...1
        }
    }

    private func title(for kind: ImageAdjustmentKind) -> String {
        switch kind {
        case .exposure: "Exposure"
        case .contrast: "Contrast"
        case .saturation: "Saturation"
        case .brightness: "Brightness"
        case .monochrome: "B&W"
        }
    }

    private func formattedValue(for kind: ImageAdjustmentKind) -> String {
        let value = value(for: kind)
        switch kind {
        case .contrast, .saturation:
            return "\(Int((value - 1) * 100))"
        default:
            return String(format: "%+.2f", value)
        }
    }
}
