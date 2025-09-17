//
//  HomeView.swift
//  OxideModules
//
//  Created by Lex Sava on 16.09.2025.
//

import AppCore
import ComposableArchitecture
import Gallery
import Settings
import SwiftUI

public enum Tab: Equatable {
    case gallery
    case settings
}

@Reducer
public struct HomeFeature {
    public init() { }
    @ObservableState
    public struct State: Equatable {
        public init(selectedTab: Tab = .gallery) {
            self.selectedTab = selectedTab
            self.galleryTab = GalleryFeature.State()
            self.settingsTab = SettingsFeature.State()
        }
        public var selectedTab: Tab
        public var galleryTab: GalleryFeature.State
        public var settingsTab: SettingsFeature.State
    }
    
    public enum Action {
        case tabSelected(Tab)
        case galleryTab(GalleryFeature.Action)
        case settingsTab(SettingsFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.galleryTab, action: \.galleryTab) {
            GalleryFeature()
        }
        Scope(state: \.settingsTab, action: \.settingsTab) {
            SettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .galleryTab, .settingsTab:
                return .none
            }
        }
    }
}


public struct HomeView: View {
    @Perception.Bindable private var store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            TabView(
                selection: $store.selectedTab.sending(\.tabSelected)
            ) {
                GalleryView(
                    store: store.scope(
                        state: \.galleryTab,
                        action: \.galleryTab
                    )
                )
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
                .tag(Tab.gallery)
                
                SettingsView(
                    store: store.scope(
                        state: \.settingsTab,
                        action: \.settingsTab
                    )
                )
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
            }
            .navigationBarStyle(.default)
        }
    }

}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }
    )
}

