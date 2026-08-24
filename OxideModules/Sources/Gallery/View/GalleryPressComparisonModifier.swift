// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI

struct GalleryComparisonVisibilityState: Equatable {
    private(set) var isPressActive = false
    private(set) var isAccessibilityHidden = false

    var areControlsHidden: Bool {
        isPressActive || isAccessibilityHidden
    }

    mutating func beginPress() {
        isPressActive = true
    }

    mutating func endPress() {
        isPressActive = false
    }

    mutating func toggleAccessibilityVisibility() {
        isAccessibilityHidden.toggle()
    }

    mutating func cancelPressIfDisabled() {
        isPressActive = false
    }
}

enum GalleryComparisonInteraction {
    static let minimumPressDuration = 0.2

    static func isEligible(
        activeTool: GalleryEditingTool,
        isPositioningSpatialEffect: Bool
    ) -> Bool {
        activeTool != .crop && !isPositioningSpatialEffect
    }
}

struct GalleryPressComparisonModifier: ViewModifier {
    let isEnabled: Bool
    let onPressVisibilityChange: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(comparisonGesture, including: isEnabled ? .all : .none)
            .onChange(of: isEnabled) { enabled in
                if !enabled {
                    onPressVisibilityChange(false)
                }
            }
    }

    private var comparisonGesture: some Gesture {
        LongPressGesture(minimumDuration: GalleryComparisonInteraction.minimumPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { phase in
                if case .second(true, _) = phase {
                    onPressVisibilityChange(true)
                }
            }
            .onEnded { _ in
                onPressVisibilityChange(false)
            }
    }
}

extension View {
    func galleryPressComparison(
        isEnabled: Bool,
        onPressVisibilityChange: @escaping (Bool) -> Void
    ) -> some View {
        modifier(
            GalleryPressComparisonModifier(
                isEnabled: isEnabled,
                onPressVisibilityChange: onPressVisibilityChange
            )
        )
    }
}
