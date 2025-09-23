// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import ComposableArchitecture
import SwiftUI

@Reducer
public struct GalleryFeature {
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
 
public struct GalleryView: View {
    @Perception.Bindable private var store: StoreOf<GalleryFeature>

    public init(store: StoreOf<GalleryFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
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
}

#Preview {
    GalleryView(store: Store(
        initialState: GalleryFeature.State()) {
        GalleryFeature()
    })
}
