import SwiftUI

public enum CircularIconButtonStyle: Equatable, Sendable {
    case plain
    case surface
}

public struct CircularIconButton: View {
    private let systemName: String
    private let accessibilityLabel: String
    private let size: CGFloat
    private let style: CircularIconButtonStyle
    private let action: () -> Void

    public init(
        systemName: String,
        accessibilityLabel: String,
        size: CGFloat = 44,
        style: CircularIconButtonStyle = .plain,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.size = size
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: size, height: size)
                .background(background)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColours.appForegroundColor)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var background: some View {
        if style == .surface {
            Circle().fill(AppColours.appSurfaceColor)
        }
    }
}
