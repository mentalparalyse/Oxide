// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit

public final class AppDelegate: NSObject, UIApplicationDelegate {
    
    public let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        store.send(.didFinishLaunching)
        // Perform any app setup here.
        return true
    }

}
