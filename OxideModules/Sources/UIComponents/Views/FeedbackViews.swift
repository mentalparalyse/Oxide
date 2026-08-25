import SwiftUI

public enum ToastStyle: Equatable, Sendable {
    case success
    case error
}

public struct ToastView: View {
    private let message: String
    private let style: ToastStyle

    public init(message: String, style: ToastStyle) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColours.appForegroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(background, in: Capsule())
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
    }

    private var background: Color {
        style == .success ? AppColours.buttonBacground : AppColours.appDestructiveColor
    }
}

public struct ConfirmationSheet: View {
    private let title: String
    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let isDestructive: Bool
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    public init(
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.6).ignoresSafeArea().onTapGesture(perform: onCancel)
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title).font(.system(size: 18, weight: .semibold))
                    Text(message).font(.system(size: 14)).foregroundStyle(AppColours.appMutedForegroundColor)
                }
                .padding(.vertical, 24)
                Divider().background(AppColours.appBorderColor)
                actionButton(confirmTitle, color: isDestructive ? AppColours.appDestructiveColor : AppColours.accent, action: onConfirm)
                Divider().background(AppColours.appBorderColor)
                actionButton(cancelTitle, color: AppColours.appForegroundColor, action: onCancel)
            }
            .foregroundStyle(AppColours.appForegroundColor)
            .background(AppColours.appSurfaceColor, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private func actionButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
    }
}
