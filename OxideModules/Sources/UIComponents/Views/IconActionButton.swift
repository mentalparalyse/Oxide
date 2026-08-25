import SwiftUI

public struct IconActionButton: View {
    private let systemName: String
    private let title: String
    private let foreground: Color
    private let background: Color
    private let action: () -> Void

    public init(
        systemName: String,
        title: String,
        foreground: Color = AppColours.appForegroundColor,
        background: Color = Color.white.opacity(0.1),
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.title = title
        self.foreground = foreground
        self.background = background
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 48, height: 48)
                    .background(background, in: Circle())
                Text(title)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
