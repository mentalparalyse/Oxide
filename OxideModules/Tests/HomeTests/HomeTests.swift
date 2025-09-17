//
//  HomeTests.swift
//  OxideModules
//
//  Created by Lex Sava on 16.09.2025.
//

import ComposableArchitecture
import Testing
@testable import Home

@MainActor
struct HomeTests {

    @Test func testTabSelected() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = TestStoreOf<HomeFeature>(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        #expect(store.state.selectedTab == .gallery)
        await store.send(.tabSelected(.settings)) {
            $0.selectedTab = .settings
        }
    }

}
