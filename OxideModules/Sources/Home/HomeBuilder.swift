// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore

@MainActor
public enum HomeBuilder {
    public static func build(coordinator: any RootCoordinatorProtocol) -> HomeView {
        HomeView()
    }
}
