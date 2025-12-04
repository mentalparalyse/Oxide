// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import Gallery
import Settings
import SwiftUI

public enum Tab: Equatable {
    case gallery
    case settings
}

public struct HomeView: View {
 
    @State private var selectedTab: Tab = .gallery
    
   public var body: some View {
       TabView(selection: $selectedTab) {
           GalleryView()
               .tabItem {
                   Label("Gallery", systemImage: "photo.on.rectangle")
               }
               .tag(Tab.gallery)
           
           SettingsView()
               .tabItem {
                   Label("Settings", systemImage: "gear")
               }
               .tag(Tab.settings)
       }
       .navigationBarStyle(.default)
    }
}
