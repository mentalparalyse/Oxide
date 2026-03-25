// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import UIComponents
import SwiftUI

public struct SettingsView: View {
    
    public init() { }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColours.appColor
                    .ignoresSafeArea()
                Text("Settings")
                    .foregroundStyle(AppColours.appForegroundColor)
            }
            .navigationBarStyle(.default)
        }
    }
}
