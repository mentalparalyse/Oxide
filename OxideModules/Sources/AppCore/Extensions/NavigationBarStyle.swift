//
//  NavigationView+Extension.swift
//  Oxide
//
//  Created by Lex Sava on 10.09.2025.
//

import SwiftUI

public struct OxideNavigationBarStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var font: Font
    var hasBackButton: Bool
    var text: String // TODO: Add typed text
}

public extension OxideNavigationBarStyle {
    @MainActor static let `default` = OxideNavigationBarStyle(
        backgroundColor: AppColours.appColor,
        foregroundColor: AppColours.navigationForegroundColor,
        font: .system(size: 16, weight: .black, design: .monospaced),
        hasBackButton: true,
        text: "Oxide"
    )
}

private struct NavigationBarStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = OxideNavigationBarStyle(
        backgroundColor: AppColours.appColor,
        foregroundColor: AppColours.appForegroundColor,
        font: .system(size: 16),
        hasBackButton: false,
        text: "Oxide"
    )
}

 
public extension EnvironmentValues {
    var navigationBarStyle: OxideNavigationBarStyle {
        get { self[NavigationBarStyleKey.self] }
        set { self[NavigationBarStyleKey.self] = newValue }
    }
}

public struct NavigationBarStyleModifier: ViewModifier {
    public let style: OxideNavigationBarStyle
    @Environment(\.navigationBarStyle) private var currentStyle

    public func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(style.hasBackButton)
            .toolbarBackground(style.backgroundColor, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(style.text)
                        .font(style.font)
                        .foregroundColor(style.foregroundColor)
                }
            }
    }
}

public extension View {
    func navigationBarStyle(_ style: OxideNavigationBarStyle) -> some View {
        environment(\.navigationBarStyle, style)
            .modifier(NavigationBarStyleModifier(style: style))
    }
}
