// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ComposableArchitecture
import Root
import AppCore
import SwiftUI

@main
struct OxideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(store: appDelegate.store)
        }
    }
}
