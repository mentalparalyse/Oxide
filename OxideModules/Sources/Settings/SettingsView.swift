//
//  SettingsView.swift
//  OxideModules
//
//  Created by Lex Sava on 16.09.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct SettingsFeature {
    public init() { }
    
    @ObservableState
    public struct State: Equatable {
        public init() { }
    }
    
    public enum Action { }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

public struct SettingsView: View {
    @Perception.Bindable private var store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            Text("Settings!")
        }
    }
}

#Preview {
    SettingsView(
        store: Store(
            initialState: SettingsFeature.State()
        ) {
            SettingsFeature()
        }
    )
}
