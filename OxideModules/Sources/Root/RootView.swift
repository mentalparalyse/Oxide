//
//  RootView.swift
//  OxideModules
//
//  Created by Lex Sava on 16.09.2025.
//

import SwiftUI
import Home
import ComposableArchitecture

@Reducer(state: .equatable)
public enum RootMode {
    case launching
    case home(HomeFeature)
}

@Reducer
public struct RootFeature {
    
    public init() { }
    
    @ObservableState
    public struct State: Equatable {
        public init() { }
        var mode: RootMode.State? = .launching
    }
    
    public enum Action {
        case didFinishLaunching
        case mode(RootMode.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                state.mode = .home(HomeFeature.State())
                return .none
            case .mode:
                return .none
            }
        }
        .ifLet(\.mode, action: \.mode) {
            RootMode.body
        }
    }
}

public struct RootView: View {
    @Perception.Bindable private var store: StoreOf<RootFeature>
    
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            if let store = store.scope(state: \.mode, action: \.mode) {
                switch store.case {
                case .launching:
                    Text("Hello, Loading!")
                case let .home(homeStore):
                    HomeView(store: homeStore)
                }
            }
        }
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    RootView(
        store: appDelegate.store
    ).onAppear {
        appDelegate.store.send(.didFinishLaunching)
    }
}
