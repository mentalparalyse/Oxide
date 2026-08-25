import SwiftUI
import UIComponents

struct GalleryZoomControlsView: View {
    let scale: CGFloat
    let zoomOut: () -> Void
    let reset: () -> Void
    let zoomIn: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            button(systemName: "minus.magnifyingglass", label: "Zoom out", action: zoomOut)

            Button(action: reset) {
                Text("\(Int((scale * 100).rounded()))%")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .frame(minWidth: 48, minHeight: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset zoom")

            button(systemName: "plus.magnifyingglass", label: "Zoom in", action: zoomIn)
        }
        .foregroundStyle(AppColours.appForegroundColor)
        .padding(4)
        .background(.black.opacity(0.58), in: Capsule())
    }

    private func button(
        systemName: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
