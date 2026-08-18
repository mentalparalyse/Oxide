// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

enum GalleryEditingTool: String, CaseIterable, Identifiable {
    case filters
    case adjustments
    case crop
    case rotate

    var id: Self { self }

    var title: String {
        switch self {
        case .filters: "Filters"
        case .adjustments: "Adjust"
        case .crop: "Crop"
        case .rotate: "Rotate"
        }
    }

    var systemImage: String {
        switch self {
        case .filters: "camera.filters"
        case .adjustments: "slider.horizontal.3"
        case .crop: "crop"
        case .rotate: "rotate.right"
        }
    }
}

struct GalleryEditingToolTabBar: View {
    @Binding var selection: GalleryEditingTool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GalleryEditingTool.allCases) { tool in
                Button {
                    selection = tool
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tool.systemImage)
                            .font(.system(size: 19, weight: .medium))
                            .frame(height: 22)

                        Text(tool.title)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(
                        selection == tool
                            ? AppColours.buttonBacground
                            : AppColours.appMutedForegroundColor
                    )
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tool.title)
                .accessibilityAddTraits(selection == tool ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColours.appColor)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColours.appBorderColor.opacity(0.65))
                .frame(height: 1)
        }
    }
}
