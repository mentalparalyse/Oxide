//
//  AppDelegate.swift
//  OxideModules
//
//  Created by Lex Sava on 16.09.2025.
//

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
