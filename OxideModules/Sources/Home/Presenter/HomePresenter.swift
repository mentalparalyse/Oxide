// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
public final class HomePresenter: ObservableObject {
    @Published var selectedTab: Tab

    private let router: HomeRouterProtocol

    init(interactor: HomeInteractorProtocol, router: HomeRouterProtocol) {
        self.selectedTab = interactor.defaultTab()
        self.router = router
    }
}
