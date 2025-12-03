// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

@MainActor
public enum SplashBuilder {
    public static func build(coordinator: any RootCoordinatorProtocol) -> some View {
        let interactor = SplashInteractor()
        let router = SplashRouter(coordinator: coordinator)
        let presenter = SplashPresenter(interactor: interactor, router: router)
        return SplashView(presenter: presenter)
    }
}
