// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

public final class AppState: ObservableObject {
    @Published public var route: Route = .splash
    @AppStorage("com.oxide.isOnboardingCompleted") public var isOnboardingCompleted = false
    public init() { }
}

public final class RootCoordinator: ObservableObject, RootCoordinatorProtocol {
    @ObservedObject private var state: AppState
    private let analytics: any AppAnalyticsTracking
    
    public init(_ state: AppState, analytics: any AppAnalyticsTracking) {
        self.state = state
        self.analytics = analytics
    }
    
    public func start() {
        analytics.track(.appStarted)
        state.route = .splash
    }
    
    public func finishSplash() {
        if state.isOnboardingCompleted {
            state.route = .home
        } else {
            state.route = .onboarding
        }
    }
    
    public func finishOnboarding() {
        state.isOnboardingCompleted = true
        state.route = .home
    }
}
