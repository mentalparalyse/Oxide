// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
@testable import Home

@MainActor
struct HomeTests {

    @Test func presenterUsesInteractorDefaultTab() async throws {
        let presenter = HomePresenter(
            interactor: StubHomeInteractor(defaultTab: .settings),
            router: StubHomeRouter()
        )

        #expect(presenter.selectedTab == .settings)
    }

    @Test func presenterAllowsTabSelectionBindingUpdates() async throws {
        let presenter = HomePresenter(
            interactor: StubHomeInteractor(defaultTab: .gallery),
            router: StubHomeRouter()
        )

        presenter.selectedTab = .settings

        #expect(presenter.selectedTab == .settings)
    }

}

@MainActor
private struct StubHomeInteractor: HomeInteractorProtocol {
    let defaultTabValue: Tab

    init(defaultTab: Tab) {
        self.defaultTabValue = defaultTab
    }

    func defaultTab() -> Tab {
        defaultTabValue
    }
}

@MainActor
private struct StubHomeRouter: HomeRouterProtocol { }
