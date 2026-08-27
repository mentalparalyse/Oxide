import AppCore
import Home
import Onboarding
import SwiftUI

@MainActor
public enum RootBuilder {
    public static func build(
        coordinator: any RootCoordinatorProtocol,
        appState: AppState,
        analytics: any AppAnalyticsTracking
    ) -> some View {
        RootView(
            coordinator: coordinator,
            appState: appState,
            homeView: AnyView(HomeBuilder.build(coordinator: coordinator, analytics: analytics)),
            onboardingView: AnyView(OnboardingBuilder.build(coordinator: coordinator, analytics: analytics))
        )
    }
}
