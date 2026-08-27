// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import UIComponents
import Home
import Onboarding
import Splash
import SwiftUI

public struct RootView: View {
    @ObservedObject var appState: AppState
    let coordinator: any RootCoordinatorProtocol
    private let homeView: AnyView
    private let onboardingView: AnyView
    
    init(
        coordinator: any RootCoordinatorProtocol,
        appState: AppState,
        homeView: AnyView,
        onboardingView: AnyView
    ) {
        self.coordinator = coordinator
        self.appState = appState
        self.homeView = homeView
        self.onboardingView = onboardingView
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .ignoresSafeArea()
            switch appState.route {
            case .home:
                homeView
            case .onboarding:
                onboardingView
            case .splash:
                SplashBuilder.build(coordinator: coordinator)
            }
        }
    }
}
