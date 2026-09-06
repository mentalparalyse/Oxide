// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryCropControlsView: View {
    let selectedAspectRatio: Double?
    let onSelect: (Double?) -> Void
    let onDone: () -> Void
    
    private let options: [CropOption] = [
        CropOption(title: "Free", aspectRatio: nil),
        CropOption(title: "1:1", aspectRatio: 1),
        CropOption(title: "4:3", aspectRatio: 4.0 / 3.0),
        CropOption(title: "16:9", aspectRatio: 16.0 / 9.0)
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(options) { option in
                    Button {
                        onSelect(option.aspectRatio)
                    } label: {
                        Text(option.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(isSelected(option) ? AppColours.appForegroundColor : AppColours.appMutedForegroundColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(background(for: option), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            Button("Done", action: onDone)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColours.accent, in: RoundedRectangle(cornerRadius: 8))
                .buttonStyle(.plain)
                .accessibilityIdentifier("crop.done")
        }
    }
    
    private func isSelected(_ option: CropOption) -> Bool {
        switch (option.aspectRatio, selectedAspectRatio) {
        case (nil, nil):
            return true
        case let (lhs?, rhs?):
            return abs(lhs - rhs) < 0.001
        default:
            return false
        }
    }
    
    private func background(for option: CropOption) -> Color {
        isSelected(option) ? AppColours.appBorderColor : AppColours.appSurfaceColor
    }
}

private struct CropOption: Identifiable {
    let title: String
    let aspectRatio: Double?
    
    var id: String {
        title
    }
}
