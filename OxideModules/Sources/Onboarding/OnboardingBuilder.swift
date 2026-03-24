// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

@MainActor
public enum OnboardingBuilder {
    public static func build(coordinator: any RootCoordinatorProtocol) -> some View {
        let interactor = OnboardingInteractor()
        let router = OnboardingRouter(coordinator: coordinator)
        let presenter = OnboardingPresenter(interactor: interactor, router: router)
        return OnboardingView(presenter: presenter)
    }
}
