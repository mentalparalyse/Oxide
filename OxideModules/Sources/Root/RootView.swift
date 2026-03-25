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
    
    public init(coordinator: any RootCoordinatorProtocol, appState: AppState) {
        self.coordinator = coordinator
        self.appState = appState
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .ignoresSafeArea()
            switch appState.route {
            case .home:
                HomeBuilder.build(coordinator: coordinator)
            case .onboarding:
                OnboardingBuilder.build(coordinator: coordinator)
            case .splash:
                SplashBuilder.build(coordinator: coordinator)
            }
        }
    }
}
