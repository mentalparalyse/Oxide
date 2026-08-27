import SwiftUI
import UIComponents

struct GalleryEffectPresetEditorView<Content: View>: View {
    let title: String
    let onBack: () -> Void
    let onReset: () -> Void
    let content: Content

    init(
        title: String,
        onBack: @escaping () -> Void,
        onReset: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onBack = onBack
        self.onReset = onReset
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBack) {
                    Label(title, systemImage: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
                Spacer()
                Button("Reset", action: onReset)
                    .font(.system(size: 12, weight: .medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColours.appMutedForegroundColor)
            }
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) { content }
            }
        }
        .padding(.horizontal, 18)
    }
}
