// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Root
import AppCore
import SwiftUI

@main
struct OxideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var appState: AppState
    @StateObject private var coordinator: RootCoordinator
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _coordinator = StateObject(wrappedValue: RootCoordinator(appState))
    }
    var body: some Scene {
        WindowGroup {
            RootView(
                coordinator: coordinator,
                appState: appState
            )
            .onAppear { coordinator.start() }
        }
    }
}
