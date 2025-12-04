// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import SwiftUI

@MainActor
public enum OnboardingBuilder {
    public static func build(_ coordinator: any RootCoordinatorProtocol) -> some View {
        let interactor = OnboardintInteractor()
        let router = OnboardingRouter(coordinator: coordinator)
        let presenter = OnboardingPresenter(interactor: interactor, rotuter: router)
        return OnboardingView(presenter: presenter)
    }
}
