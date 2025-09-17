//
//  OxideApp.swift
//  Oxide
//
//  Created by Lex Sava on 08.09.2025.
//

import ComposableArchitecture
import Root
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
