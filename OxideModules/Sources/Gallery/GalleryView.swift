// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import UIComponents
import SwiftUI

public struct GalleryView: View {
    
    public init() { }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColours.appColor
                    .ignoresSafeArea()
                Text("Hello, World!")
                    .foregroundStyle(AppColours.appForegroundColor)
            }
            .navigationBarStyle(.default)
        }
    }  
}
