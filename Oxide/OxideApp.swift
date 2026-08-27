// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Root
import AppCore
import SwiftUI

@main
struct OxideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var appState: AppState
    @StateObject private var coordinator: RootCoordinator
    private let dependencies: AnalyticsDependencies
    
    init() {
        let appState = AppState()
        let dependencies = AnalyticsDependencies()
        self.dependencies = dependencies
        _appState = StateObject(wrappedValue: appState)
        _coordinator = StateObject(wrappedValue: RootCoordinator(appState, analytics: dependencies.tracker))
    }
    var body: some Scene {
        WindowGroup {
            RootBuilder.build(
                coordinator: coordinator,
                appState: appState,
                analytics: dependencies.tracker
            )
            .onAppear { coordinator.start() }
        }
    }
}
