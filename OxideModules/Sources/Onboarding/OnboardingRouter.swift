// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import Foundation

@MainActor
protocol OnboardingRouterProtocol {
    func finishOnboarding()
}

final class OnboardingRouter: OnboardingRouterProtocol {
    private weak var coordinator: (any RootCoordinatorProtocol)?
    
    init(coordinator: (any RootCoordinatorProtocol)?) {
        self.coordinator = coordinator
    }
    
    func finishOnboarding() {
        coordinator?.finishOnboarding()
    }
}
