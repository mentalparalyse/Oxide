// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore

@MainActor
public protocol HomeRouterProtocol { }

public final class HomeRouter: HomeRouterProtocol {
    private weak var coordinator: (any RootCoordinatorProtocol)?

    init(coordinator: any RootCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}
