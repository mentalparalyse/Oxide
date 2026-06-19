// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

@MainActor
public enum HomeBuilder {
    public static func build(coordinator: any RootCoordinatorProtocol) -> some View {
        let interactor = HomeInteractor()
        let router = HomeRouter(coordinator: coordinator)
        let presenter = HomePresenter(interactor: interactor, router: router)
        return HomeView(presenter: presenter)
    }
}
